import { HttpStatus, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { compare } from 'bcrypt';
import { Repository } from 'typeorm';
import { LoginRequestDto } from '../dto/login-request.dto';
import { Member } from '../entity/member.entity';
import { ApiException } from '../exception/api.exception';

// Use the same bcrypt cost for lookups that do not find an account.
const DUMMY_HASH =
  '$2b$10$C6UzMDM.H6dfI/f/IKcEe.2qUBXyyOf0EDSLcttZcuX7DTvXWS3.K';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(Member) private readonly members: Repository<Member>,
    private readonly jwt: JwtService,
  ) {}

  async login({ email, password }: LoginRequestDto) {
    const member = await this.members.findOneBy({ email });
    const matches = await compare(password, member?.password ?? DUMMY_HASH);

    if (!member || !matches) {
      throw new ApiException(
        HttpStatus.UNAUTHORIZED,
        'AUTH401_1',
        '이메일 또는 비밀번호가 올바르지 않습니다.',
      );
    }

    const accessToken = await this.jwt.signAsync({
      sub: String(member.memberId),
      email: member.email,
    });
    return { nickname: member.nickname, accessToken };
  }
}
