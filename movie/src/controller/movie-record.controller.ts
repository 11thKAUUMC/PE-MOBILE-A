import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { LoginMember } from '../decorator/login-member.decorator';
import { CreateMovieRecordDto } from '../dto/create-movie-record.dto';
import { AuthGuard } from '../guard/auth.guard';
import { MovieRecordService } from '../service/movie-record.service';

@Controller('movie-records')
@UseGuards(AuthGuard)
export class MovieRecordController {
  constructor(private readonly movieRecords: MovieRecordService) {}

  @Post()
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
