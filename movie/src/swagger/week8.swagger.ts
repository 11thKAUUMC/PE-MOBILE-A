import { applyDecorators } from '@nestjs/common';
import { ApiBearerAuth, ApiResponse, ApiTags } from '@nestjs/swagger';

export const movieIdSchema = {
  type: 'integer',
  minimum: 1,
  maximum: Number.MAX_SAFE_INTEGER,
  example: 550,
};

export const favoriteExample = {
  favoriteId: 1,
  movieId: 550,
  createdAt: '2026-11-21T00:00:00.000Z',
};

const errors = {
  invalid: ['COMMON400', '영화 ID는 양수여야 합니다.'],
  noToken: ['AUTH401_2', '로그인이 필요한 요청입니다.'],
  invalidToken: ['AUTH401_3', '유효하지 않은 토큰입니다.'],
  expiredToken: ['AUTH401_4', '토큰이 만료되었습니다. 다시 로그인해주세요.'],
  memberMissing: ['MEMBER404_1', '해당 회원을 찾을 수 없습니다.'],
  favoriteMissing: ['FAVORITE404_1', '즐겨찾기한 영화를 찾을 수 없습니다.'],
  favoriteDuplicate: ['FAVORITE409_1', '이미 이 영화를 즐겨찾기하셨습니다.'],
  ratingDuplicate: ['RATING409_1', '이미 이 영화에 평점을 남기셨습니다.'],
} as const;

export function ApiMemberEndpoints(tag: string) {
  return applyDecorators(
    ApiTags(tag),
    ApiBearerAuth(),
    ApiWeek8Errors(
      401,
      'Bearer 토큰 누락, 검증 실패 또는 만료',
      'noToken',
      'invalidToken',
      'expiredToken',
    ),
  );
}

export function ApiWeek8Success(
  status: 200 | 201,
  message: string,
  result: unknown,
) {
  return ApiResponse({
    status,
    description: message,
    content: {
      'application/json': {
        example: { isSuccess: true, code: `COMMON${status}`, message, result },
      },
    },
  });
}

export function ApiWeek8Errors(
  status: 400 | 401 | 404 | 409,
  description: string,
  ...cases: (keyof typeof errors)[]
) {
  const examples = Object.fromEntries(
    cases.map((key) => {
      const [code, message] = errors[key];
      return [
        code,
        {
          summary: code,
          value: { isSuccess: false, code, message, result: null },
        },
      ];
    }),
  );
  return ApiResponse({
    status,
    description,
    content: { 'application/json': { examples } },
  });
}
