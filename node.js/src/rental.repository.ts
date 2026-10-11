import { Injectable, Inject } from '@nestjs/common';
import type { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from './database.provider';

@Injectable()
export class RentalRepository {
  constructor(
    @Inject(DATABASE_CONNECTION) private readonly pool: Pool,
  ) {}

  async returnRental(rentalId: number): Promise<any> {
    const sql =
      'UPDATE rental SET returned_at = NOW() WHERE rental_id = ?';

    const [result] = await this.pool.execute(sql, [rentalId]);
    return result;
  }
}