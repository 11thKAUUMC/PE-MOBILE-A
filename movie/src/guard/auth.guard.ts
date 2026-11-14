import {
  CanActivate,
  ExecutionContext,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { JwtService, TokenExpiredError } from '@nestjs/jwt';
import type { Request } from 'express';
import { ApiException } from '../exception/api.exception';

export type AuthenticatedRequest = Request & { memberId: number };

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const token = /^Bearer\s+(\S+)$/i.exec(
      request.headers.authorization ?? '',
    )?.[1];
    if (!token) {
      throw new ApiException(
        HttpStatus.UNAUTHORIZED,
        'AUTH401_2',
        '로그인이 필요한 요청입니다.',
      );
    }

    try {
      const { sub } = await this.jwt.verifyAsync<{ sub: string }>(token);
      const memberId = Number(sub);
      if (
        typeof sub !== 'string' ||
        !/^\d+$/.test(sub) ||
        !Number.isSafeInteger(memberId) ||
        memberId < 1
      ) {
        throw new Error('Invalid JWT subject');
      }
      request.memberId = memberId;
    } catch (error) {
      if (error instanceof TokenExpiredError) {
        throw new ApiException(
          HttpStatus.UNAUTHORIZED,
          'AUTH401_4',
          '토큰이 만료되었습니다. 다시 로그인해주세요.',
        );
      }
      throw new ApiException(
        HttpStatus.UNAUTHORIZED,
        'AUTH401_3',
        '유효하지 않은 토큰입니다.',
      );
    }
    return true;
  }
}
