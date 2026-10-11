import {
  IsInt,
  Min,
  Max,
  IsString,
  IsNotEmpty,
  MaxLength,
  Matches,
  IsOptional,
} from 'class-validator';

export class CreateBookDto {
  @IsInt()
  @Min(1)
  @Max(Number.MAX_SAFE_INTEGER)
  categoryId: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  @Matches(/\S/, { message: '제목은 공백만 입력할 수 없습니다.' })
  title: string;

  @IsOptional()
  @IsString()
  description?: string;
}