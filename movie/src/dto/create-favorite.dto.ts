import { IsInt, Max, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateFavoriteDto {
  @IsInt({ message: '영화 ID는 정수여야 합니다.' })
  @Min(1, { message: '영화 ID는 양수여야 합니다.' })
  @Max(Number.MAX_SAFE_INTEGER)
  movieId: number;
}

export class FavoriteMovieParam extends CreateFavoriteDto {
  @Transform(({ value }) => (/^\d+$/.test(value) ? Number(value) : NaN))
  declare movieId: number;
}
