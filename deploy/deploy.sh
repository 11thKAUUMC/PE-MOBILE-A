#!/usr/bin/env bash
set -euo pipefail

REGION=ap-southeast-2
export AWS_REGION=$REGION AWS_DEFAULT_REGION=$REGION

SHA=$(git -C "$(dirname "$0")/.." rev-parse --short HEAD 2>/dev/null || date +%y%m%d%H%M)
ECR=$(aws ecr describe-repositories --repository-names umc-app \
        --query 'repositories[0].repositoryUri' --output text)
TG=$(aws elbv2 describe-target-groups --names umc-app-tg \
        --query 'TargetGroups[0].TargetGroupArn' --output text)
TAG="${ECR}:v1.0.0-$(date +%y-%m-%d)-${SHA}"

# 1. 이미지
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR"
docker buildx build --platform linux/arm64 --provenance=false -t "$TAG" --push "$(dirname "$0")/.."

# 2. 앞으로 "새로 뜨는" 인스턴스가 읽을 태그
aws ssm put-parameter --name /umc/app/image --type String --value "$TAG" --overwrite

# 3. "지금 떠 있는" 인스턴스를 한 대씩 교체
for ID in $(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names umc-asg \
              --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' \
              --output text); do
  echo "── $ID"

  aws elbv2 deregister-targets --target-group-arn "$TG" --targets Id="$ID"
  aws elbv2 wait target-deregistered --target-group-arn "$TG" --targets Id="$ID"

  CID=$(aws ssm send-command --instance-ids "$ID" --document-name AWS-RunShellScript \
          --parameters 'commands=["bash /opt/umc/swap.sh"]' \
          --query Command.CommandId --output text)

  until [ "$(aws ssm list-command-invocations --command-id "$CID" \
               --query 'CommandInvocations[0].Status' --output text)" != "InProgress" ]; do
    sleep 5
  done
  ST=$(aws ssm list-command-invocations --command-id "$CID" \
         --query 'CommandInvocations[0].Status' --output text)
  if [ "$ST" != "Success" ]; then
    echo "교체 실패($ST). 이 인스턴스는 타겟에서 빠진 채로 남아 있다."
    aws ssm list-command-invocations --command-id "$CID" --details \
      --query 'CommandInvocations[0].CommandPlugins[0].Output' --output text | tail -20
    exit 1
  fi

  aws elbv2 register-targets --target-group-arn "$TG" --targets Id="$ID"
  aws elbv2 wait target-in-service --target-group-arn "$TG" --targets Id="$ID"
done

echo "DEPLOY_OK tag=$TAG"
