import { ApiException } from '../exception/api.exception';
import { MemberInfoResponseDto } from '../dto/member-info-response.dto';
import { MemberUpdateRequestDto } from '../dto/member-update-request.dto';
import { ConflictException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, QueryFailedError, Repository } from 'typeorm';
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

  async getMyInfo(memberId: number) {
    const member = await this.memberRepository.findOneBy({ memberId });
    if (!member) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'MEMBER404_1',
        '해당 회원을 찾을 수 없습니다.',
      );
    }
    return MemberInfoResponseDto.from(member);
  }

  async updateMyInfo(memberId: number, { nickname }: MemberUpdateRequestDto) {
    await this.getMyInfo(memberId);
    const conflict = new ApiException(
      HttpStatus.CONFLICT,
      'MEMBER409_1',
      nicknameConflict.message,
    );
    if (
      await this.memberRepository.existsBy({
        nickname,
        memberId: Not(memberId),
      })
    ) {
      throw conflict;
    }

    try {
      await this.memberRepository.update(memberId, { nickname });
    } catch (error) {
      // The nickname is the only unique field changed by this query.
      if (
        error instanceof QueryFailedError &&
        error.driverError.code === 'ER_DUP_ENTRY'
      ) {
        throw conflict;
      }
      throw error;
    }
    return this.getMyInfo(memberId);
  }
}
