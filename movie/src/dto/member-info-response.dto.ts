import { Member } from '../entity/member.entity';

export class MemberInfoResponseDto {
  email: string;
  nickname: string;
  createdAt: Date;

  static from({ email, nickname, createdAt }: Member): MemberInfoResponseDto {
    return { email, nickname, createdAt };
  }
}
