import { HttpStatus, Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { CreateMovieRecordDto } from '../dto/create-movie-record.dto';
import { FavoriteResponseDto } from '../dto/favorite-response.dto';
import { RatingResponseDto } from '../dto/rating-response.dto';
import { Favorite } from '../entity/favorite.entity';
import { Member } from '../entity/member.entity';
import { Rating } from '../entity/rating.entity';
import { ApiException } from '../exception/api.exception';
import { saveFavorite } from './favorite.service';
import { saveRating } from './rating.service';

type MovieRecordResponse = {
  rating: RatingResponseDto;
  favorite: FavoriteResponseDto | null;
};

@Injectable()
export class MovieRecordService {
  constructor(private readonly dataSource: DataSource) {}

  create(
    memberId: number,
    dto: CreateMovieRecordDto,
  ): Promise<MovieRecordResponse> {
    return this.dataSource.transaction(async (manager) => {
      const member = await manager
        .getRepository(Member)
        .findOneBy({ memberId });
      if (!member) {
        throw new ApiException(
          HttpStatus.NOT_FOUND,
          'MEMBER404_1',
          '해당 회원을 찾을 수 없습니다.',
        );
      }

      const rating = await saveRating(
        manager.getRepository(Rating),
        member,
        dto,
      );
      const favorite = dto.addToFavorites
        ? await saveFavorite(
            manager.getRepository(Favorite),
            member,
            dto.movieId,
          )
        : null;

      return { rating, favorite };
    });
  }
}
