import { Injectable, NotFoundException } from '@nestjs/common';
import type { ResultSetHeader } from 'mysql2/promise';
import { RentalRepository } from './rental.repository';

@Injectable()
export class RentalService {
  constructor(private readonly rentalRepository: RentalRepository) {}

  async returnRental(rentalId: number): Promise<string> {
    const result = await this.rentalRepository.returnRental(
      rentalId,
    ) as ResultSetHeader;

    if (result.affectedRows === 0) {
      throw new NotFoundException('대여 기록을 찾을 수 없습니다.');
    }

    return '도서 반납이 완료되었습니다!';
  }
}