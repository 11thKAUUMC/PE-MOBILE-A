// src/book.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { BookRepository } from './book.repository';
import { BookResponseDto } from './dto/book-response.dto';
import { CreateBookDto } from './dto/create-book.dto';

@Injectable()
export class BookService {
  // 창고지기(BookRepository)를 주입받습니다.
  constructor(private readonly bookRepository: BookRepository) {}

  async getAllBooks(): Promise<BookResponseDto[]> {
    const books = await this.bookRepository.findAll();

    return books.map((book) => BookResponseDto.from(book));
  }

  // book.service.ts에 추가
  async createBook(dto: CreateBookDto): Promise<BookResponseDto> {
    const category = await this.bookRepository.findCategoryById(
      String(dto.categoryId),
    );

    if (!category) {
      throw new NotFoundException('존재하지 않는 카테고리입니다.');
    }

    const book = await this.bookRepository.create(dto, category);

    return BookResponseDto.from(book);
  }
}