import { ApiException } from '../exception/api.exception';
import { HttpStatus, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateRatingDto, UpdateRatingDto } from '../dto/rating-write.dto';
import { ratingConflict } from '../filter/http-exception.filter';
import { Rating } from '../entity/rating.entity';
import { Member } from '../entity/member.entity';
import { RatingResponseDto } from '../dto/rating-response.dto';

export async function saveRating(
  repository: Repository<Rating>,
  member: Member,
  { movieId, score, comment }: CreateRatingDto,
): Promise<RatingResponseDto> {
  if (
    await repository.existsBy({
      member: { memberId: member.memberId },
      movieId,
    })
  ) {
    throw new ApiException(
      HttpStatus.CONFLICT,
      ratingConflict.code,
      ratingConflict.message,
    );
  }

  const rating = await repository.save(
    repository.create({ member, movieId, score, comment: comment ?? null }),
  );
  return RatingResponseDto.from(rating);
}

@Injectable()
export class RatingService {
  constructor(
    @InjectRepository(Rating)
    private readonly ratingRepository: Repository<Rating>,

    @InjectRepository(Member)
    private readonly memberRepository: Repository<Member>,
  ) {}

  async getRatingsByMember(memberId: number): Promise<RatingResponseDto[]> {
    const member = await this.memberRepository.findOneBy({ memberId });

    if (!member) {
      throw new NotFoundException('존재하지 않는 유저입니다.');
    }

    const ratings = await this.ratingRepository.find({
      where: { member: { memberId } },
      order: { ratingId: 'DESC' },
    });

    return ratings.map((rating) => RatingResponseDto.from(rating));
  }

  async create(memberId: number, dto: CreateRatingDto) {
    const member = await this.memberRepository.findOneBy({ memberId });
    if (!member) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'MEMBER404_1',
        '해당 회원을 찾을 수 없습니다.',
      );
    }
    return saveRating(this.ratingRepository, member, dto);
  }

  async update(
    memberId: number,
    ratingId: number,
    { score, comment }: UpdateRatingDto,
  ) {
    const rating = await this.findOwnedRating(memberId, ratingId);
    const result = await this.ratingRepository.update(ratingId, {
      score,
      comment: comment ?? null,
    });
    if (!result.affected) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'RATING404_1',
        '해당 평점을 찾을 수 없습니다.',
      );
    }
    const updated = await this.ratingRepository.findOneBy({
      ratingId: rating.ratingId,
    });
    if (!updated) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'RATING404_1',
        '해당 평점을 찾을 수 없습니다.',
      );
    }
    return RatingResponseDto.from(updated);
  }

  async delete(memberId: number, ratingId: number) {
    await this.findOwnedRating(memberId, ratingId);
    const result = await this.ratingRepository.delete(ratingId);
    if (!result.affected) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'RATING404_1',
        '해당 평점을 찾을 수 없습니다.',
      );
    }
  }

  private async findOwnedRating(memberId: number, ratingId: number) {
    const rating = await this.ratingRepository.findOne({
      where: { ratingId },
      relations: { member: true },
    });
    if (!rating) {
      throw new ApiException(
        HttpStatus.NOT_FOUND,
        'RATING404_1',
        '해당 평점을 찾을 수 없습니다.',
      );
    }
    if (Number(rating.member.memberId) !== memberId) {
      throw new ApiException(
        HttpStatus.FORBIDDEN,
        'RATING403_1',
        '본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.',
      );
    }
    return rating;
  }
}
