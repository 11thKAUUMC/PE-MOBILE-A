import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { LoginMember } from '../decorator/login-member.decorator';
import { AuthGuard } from '../guard/auth.guard';
import { CreateRatingDto, UpdateRatingDto } from '../dto/rating-write.dto';
import { RatingService } from '../service/rating.service';

@Controller()
export class RatingController {
  constructor(private readonly ratingService: RatingService) {}

  @Get('members/:memberId/ratings')
  getMemberRatings(@Param('memberId', ParseIntPipe) memberId: number) {
    return this.ratingService.getRatingsByMember(memberId);
  }

  @Post('ratings')
  @UseGuards(AuthGuard)
  async create(@LoginMember() memberId: number, @Body() dto: CreateRatingDto) {
    return {
      isSuccess: true,
      code: 'COMMON201',
      message: '평점을 등록했습니다.',
      result: await this.ratingService.create(memberId, dto),
    };
  }

  @Patch('ratings/:ratingId')
  @UseGuards(AuthGuard)
  async update(
    @LoginMember() memberId: number,
    @Param('ratingId', ParseIntPipe) ratingId: number,
    @Body() dto: UpdateRatingDto,
  ) {
    const result = await this.ratingService.update(memberId, ratingId, dto);
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '평점을 수정했습니다.',
      result,
    };
  }

  @Delete('ratings/:ratingId')
  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.OK)
  async delete(
    @LoginMember() memberId: number,
    @Param('ratingId', ParseIntPipe) ratingId: number,
  ) {
    await this.ratingService.delete(memberId, ratingId);
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '평점을 삭제했습니다.',
      result: null,
    };
  }
}
