import { IsBoolean } from 'class-validator';
import { CreateRatingDto } from './rating-write.dto';

export class CreateMovieRecordDto extends CreateRatingDto {
  @IsBoolean({ message: '즐겨찾기 추가 여부는 true 또는 false여야 합니다.' })
  addToFavorites: boolean;
}
