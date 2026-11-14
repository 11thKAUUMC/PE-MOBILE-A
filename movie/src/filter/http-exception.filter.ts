import { ApiException } from '../exception/api.exception';
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';
import { QueryFailedError } from 'typeorm';

export const emailConflict = {
  code: 'MEMBER4091',
  message: '이미 사용 중인 이메일입니다.',
};

export const nicknameConflict = {
  code: 'MEMBER4092',
  message: '이미 사용 중인 닉네임입니다.',
};

export const ratingConflict = {
  code: 'RATING409_1',
  message: '이미 이 영화에 평점을 남기셨습니다.',
};

const duplicateKeys: ReadonlyMap<string, { code: string; message: string }> =
  new Map([
    ['email', emailConflict],
    ['nickname', nicknameConflict],
    ['uk_rating_member_movie', ratingConflict],
  ]);

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const response = host.switchToHttp().getResponse<Response>();
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse() as
        string | { code?: string; message: string | string[] };
      const message = typeof body === 'string' ? body : body.message;
      const code = typeof body === 'string' ? undefined : body.code;
      response.status(status).json({
        isSuccess: false,
        code:
          exception instanceof ApiException
            ? exception.code
            : (code ?? 'COMMON' + status),
        message: Array.isArray(message) ? message[0] : message,
        result: null,
      });
      return;
    }

    if (
      exception instanceof QueryFailedError &&
      exception.driverError.code === 'ER_DUP_ENTRY'
    ) {
      const key = /for key '([^']+)'$/
        .exec(exception.driverError.sqlMessage ?? '')?.[1]
        .split('.')
        .at(-1);
      const error = (key && duplicateKeys.get(key)) || {
        code: 'COMMON409',
        message: '이미 존재하는 데이터입니다.',
      };
      response.status(409).json({ isSuccess: false, ...error, result: null });
      return;
    }

    this.logger.error(
      exception instanceof Error ? exception.name : 'Unknown error',
    );
    response.status(500).json({
      isSuccess: false,
      code: 'COMMON500',
      message: '서버 오류가 발생했습니다.',
      result: null,
    });
  }
}
