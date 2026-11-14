import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateRatingDto, UpdateRatingDto } from '../dto/rating-write.dto';
import { ratingConflict } from '../filter/http-exception.filter';
import { Rating } from '../entity/rating.entity';
import { Member } from '../entity/member.entity';
import { RatingResponseDto } from '../dto/rating-response.dto';

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

    return ratings.map(RatingResponseDto.from);
  }

  async create(memberId: number, { movieId, score, comment }: CreateRatingDto) {
    const member = await this.memberRepository.findOneBy({ memberId });
    if (!member) {
      throw new NotFoundException('존재하지 않는 유저입니다.');
    }
    if (
      await this.ratingRepository.existsBy({ member: { memberId }, movieId })
    ) {
      throw new ConflictException(ratingConflict);
    }
    const rating = await this.ratingRepository.save(
      this.ratingRepository.create({
        member,
        movieId,
        score,
        comment: comment ?? null,
      }),
    );
    return rating.ratingId;
  }

  async update(
    memberId: number,
    ratingId: number,
    { score, comment }: UpdateRatingDto,
  ) {
    await this.checkOwnership(memberId, ratingId);
    const result = await this.ratingRepository.update(ratingId, {
      score,
      comment: comment ?? null,
    });
    if (!result.affected) {
      throw new NotFoundException('존재하지 않는 평점입니다.');
    }
  }

  async delete(memberId: number, ratingId: number) {
    await this.checkOwnership(memberId, ratingId);
    const result = await this.ratingRepository.delete(ratingId);
    if (!result.affected) {
      throw new NotFoundException('존재하지 않는 평점입니다.');
    }
  }

  private async checkOwnership(memberId: number, ratingId: number) {
    const rating = await this.ratingRepository.findOne({
      where: { ratingId },
      relations: { member: true },
    });
    if (!rating) {
      throw new NotFoundException('존재하지 않는 평점입니다.');
    }
    if (Number(rating.member.memberId) !== memberId) {
      throw new ForbiddenException(
        '본인이 작성한 평점만 수정하거나 삭제할 수 있습니다.',
      );
    }
  }
}
