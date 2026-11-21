import { HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  FavoriteResponseDto,
  FavoriteStatusResponseDto,
} from '../dto/favorite-response.dto';
import { Favorite } from '../entity/favorite.entity';
import { Member } from '../entity/member.entity';
import { ApiException } from '../exception/api.exception';
import { favoriteConflict } from '../filter/http-exception.filter';

export async function saveFavorite(
  repository: Repository<Favorite>,
  member: Member,
  movieId: number,
): Promise<FavoriteResponseDto> {
  if (
    await repository.existsBy({
      member: { memberId: member.memberId },
      movieId,
    })
  ) {
    throw new ApiException(
      HttpStatus.CONFLICT,
      favoriteConflict.code,
      favoriteConflict.message,
    );
  }
  return FavoriteResponseDto.from(
    await repository.save(repository.create({ member, movieId })),
  );
}

@Injectable()
export class FavoriteService {
  constructor(
    @InjectRepository(Favorite)
    private readonly favorites: Repository<Favorite>,
    @InjectRepository(Member)
    private readonly members: Repository<Member>,
  ) {}

  async create(
    memberId: number,
    movieId: number,
  ): Promise<FavoriteResponseDto> {
    const member = await this.members.findOneBy({ memberId });
    if (!member) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'MEMBER404_1',
        '해당 회원을 찾을 수 없습니다.',
      );
    }
    return saveFavorite(this.favorites, member, movieId);
  }

  async getMyFavorites(memberId: number): Promise<FavoriteResponseDto[]> {
    const favorites = await this.favorites.find({
      where: { member: { memberId } },
      order: { favoriteId: 'DESC' },
    });
    return favorites.map(FavoriteResponseDto.from);
  }

  async getStatus(
    memberId: number,
    movieId: number,
  ): Promise<FavoriteStatusResponseDto> {
    return {
      isFavorite: await this.favorites.existsBy({
        member: { memberId },
        movieId,
      }),
    };
  }

  async delete(memberId: number, movieId: number): Promise<void> {
    const result = await this.favorites.delete({
      member: { memberId },
      movieId,
    });
    if (!result.affected) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'FAVORITE404_1',
        '즐겨찾기한 영화를 찾을 수 없습니다.',
      );
    }
  }
}
