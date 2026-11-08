import { ConflictException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { hash } from 'bcrypt';
import { CreateMemberDto } from '../dto/create-member.dto';
import {
  emailConflict,
  nicknameConflict,
} from '../filter/http-exception.filter';
import { Member } from '../entity/member.entity';
import { CheckResponseDto } from '../dto/check-response.dto';

@Injectable()
export class MemberService {
  constructor(
    @InjectRepository(Member)
    private readonly memberRepository: Repository<Member>,
  ) {}

  async checkNickname(nickname: string): Promise<CheckResponseDto> {
    const exists = await this.memberRepository.exists({
      where: { nickname },
    });

    return { available: !exists };
  }

  async checkEmail(email: string): Promise<CheckResponseDto> {
    const exists = await this.memberRepository.exists({
      where: { email },
    });

    return { available: !exists };
  }

  async signUp({ email, nickname, password }: CreateMemberDto) {
    if (!(await this.checkEmail(email)).available) {
      throw new ConflictException(emailConflict);
    }
    if (!(await this.checkNickname(nickname)).available) {
      throw new ConflictException(nicknameConflict);
    }

    const saved = await this.memberRepository.save(
      this.memberRepository.create({
        email,
        nickname,
        password: await hash(password, 10),
      }),
    );
    return {
      memberId: saved.memberId,
      email: saved.email,
      nickname: saved.nickname,
    };
  }
}
