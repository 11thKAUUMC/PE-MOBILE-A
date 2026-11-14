import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { AuthenticatedRequest } from '../guard/auth.guard';

export const LoginMember = createParamDecorator(
  (_: unknown, context: ExecutionContext): number =>
    context.switchToHttp().getRequest<AuthenticatedRequest>().memberId,
);
