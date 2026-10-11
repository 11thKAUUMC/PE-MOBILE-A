import { Controller, Patch, Param, ParseIntPipe } from '@nestjs/common';
import { RentalService } from './rental.service';

@Controller('rentals')
export class RentalController {
  constructor(private readonly rentalService: RentalService) {}

  @Patch(':rentalId/return')
  async returnRental(
    @Param('rentalId', ParseIntPipe) rentalId: number,
  ): Promise<string> {
    return await this.rentalService.returnRental(rentalId);
  }
}