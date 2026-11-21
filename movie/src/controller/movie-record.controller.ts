import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBody, ApiOperation } from '@nestjs/swagger';
import { LoginMember } from '../decorator/login-member.decorator';
import { CreateMovieRecordDto } from '../dto/create-movie-record.dto';
import { AuthGuard } from '../guard/auth.guard';
import { MovieRecordService } from '../service/movie-record.service';

import {
  ApiMemberEndpoints,
  ApiWeek8Errors,
  ApiWeek8Success,
  favoriteExample,
  movieIdSchema,
} from '../swagger/week8.swagger';

@ApiMemberEndpoints('영화 기록')
@Controller('movie-records')
@UseGuards(AuthGuard)
export class MovieRecordController {
  constructor(private readonly movieRecords: MovieRecordService) {}

  @Post()
  @ApiOperation({
    summary: '평점과 즐겨찾기 저장',
    description:
      'addToFavorites가 true이면 두 데이터를 한 트랜잭션에서 저장합니다. false이면 평점만 저장하고 favorite는 null을 반환합니다.',
  })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['movieId', 'score', 'addToFavorites'],
      properties: {
        movieId: movieIdSchema,
        score: { type: 'integer', minimum: 1, maximum: 5, example: 5 },
        comment: {
          type: 'string',
          maxLength: 500,
          nullable: true,
          example: '다시 보고 싶은 영화입니다.',
        },
        addToFavorites: { type: 'boolean', example: true },
      },
    },
  })
  @ApiWeek8Success(201, '영화 기록을 저장했습니다.', {
    rating: {
      ratingId: 1,
      movieId: 550,
      score: 5,
      comment: '다시 보고 싶은 영화입니다.',
      createdAt: favoriteExample.createdAt,
      updatedAt: favoriteExample.createdAt,
    },
    favorite: favoriteExample,
  })
  @ApiWeek8Errors(400, '요청 형식 오류', 'invalid')
  @ApiWeek8Errors(404, '회원 없음', 'memberMissing')
  @ApiWeek8Errors(
    409,
    '평점 또는 즐겨찾기 중복',
    'ratingDuplicate',
    'favoriteDuplicate',
  )
  async create(
    @LoginMember() memberId: number,
    @Body() dto: CreateMovieRecordDto,
  ) {
    return {
      isSuccess: true,
      code: 'COMMON201',
      message: '영화 기록을 저장했습니다.',
      result: await this.movieRecords.create(memberId, dto),
    };
  }
}
