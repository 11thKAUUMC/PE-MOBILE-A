import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBody, ApiOperation, ApiParam } from '@nestjs/swagger';
import { LoginMember } from '../decorator/login-member.decorator';
import {
  CreateFavoriteDto,
  FavoriteMovieParam,
} from '../dto/create-favorite.dto';
import { AuthGuard } from '../guard/auth.guard';
import { FavoriteService } from '../service/favorite.service';

import {
  ApiMemberEndpoints,
  ApiWeek8Errors,
  ApiWeek8Success,
  favoriteExample,
  movieIdSchema,
} from '../swagger/week8.swagger';

@ApiMemberEndpoints('즐겨찾기')
@Controller('favorites')
@UseGuards(AuthGuard)
export class FavoriteController {
  constructor(private readonly favorites: FavoriteService) {}

  @Post()
  @ApiOperation({ summary: '즐겨찾기 등록' })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['movieId'],
      properties: { movieId: movieIdSchema },
    },
  })
  @ApiWeek8Success(201, '즐겨찾기를 등록했습니다.', favoriteExample)
  @ApiWeek8Errors(400, '요청 형식 오류', 'invalid')
  @ApiWeek8Errors(404, '회원 없음', 'memberMissing')
  @ApiWeek8Errors(409, '즐겨찾기 중복', 'favoriteDuplicate')
  async create(
    @LoginMember() memberId: number,
    @Body() dto: CreateFavoriteDto,
  ) {
    return {
      isSuccess: true,
      code: 'COMMON201',
      message: '즐겨찾기를 등록했습니다.',
      result: await this.favorites.create(memberId, dto.movieId),
    };
  }

  @Get()
  @ApiOperation({ summary: '내 즐겨찾기 최신순 조회' })
  @ApiWeek8Success(200, '즐겨찾기 목록을 조회했습니다.', [favoriteExample])
  async list(@LoginMember() memberId: number) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '즐겨찾기 목록을 조회했습니다.',
      result: await this.favorites.getMyFavorites(memberId),
    };
  }

  @Get(':movieId')
  @ApiOperation({ summary: '특정 영화 즐겨찾기 여부 조회' })
  @ApiParam({ name: 'movieId', schema: movieIdSchema })
  @ApiWeek8Success(200, '즐겨찾기 여부를 조회했습니다.', { isFavorite: true })
  @ApiWeek8Errors(400, '영화 ID 형식 오류', 'invalid')
  async status(
    @LoginMember() memberId: number,
    @Param() params: FavoriteMovieParam,
  ) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '즐겨찾기 여부를 조회했습니다.',
      result: await this.favorites.getStatus(memberId, params.movieId),
    };
  }

  @Delete(':movieId')
  @ApiOperation({ summary: '즐겨찾기 해제' })
  @ApiParam({ name: 'movieId', schema: movieIdSchema })
  @ApiWeek8Success(200, '즐겨찾기를 해제했습니다.', null)
  @ApiWeek8Errors(400, '영화 ID 형식 오류', 'invalid')
  @ApiWeek8Errors(404, '즐겨찾기 없음', 'favoriteMissing')
  async delete(
    @LoginMember() memberId: number,
    @Param() params: FavoriteMovieParam,
  ) {
    await this.favorites.delete(memberId, params.movieId);
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '즐겨찾기를 해제했습니다.',
      result: null,
    };
  }
}
