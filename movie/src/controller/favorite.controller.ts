import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { LoginMember } from '../decorator/login-member.decorator';
import {
  CreateFavoriteDto,
  FavoriteMovieParam,
} from '../dto/create-favorite.dto';
import { AuthGuard } from '../guard/auth.guard';
import { FavoriteService } from '../service/favorite.service';

@Controller('favorites')
@UseGuards(AuthGuard)
export class FavoriteController {
  constructor(private readonly favorites: FavoriteService) {}

  @Post()
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
  async list(@LoginMember() memberId: number) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '즐겨찾기 목록을 조회했습니다.',
      result: await this.favorites.getMyFavorites(memberId),
    };
  }

  @Get(':movieId')
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
