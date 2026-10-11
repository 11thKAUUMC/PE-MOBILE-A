// src/book.controller.ts
import { ValidationPipe } from '@nestjs/common';
import { CreateBookDto } from './dto/create-book.dto';
import { BookResponseDto } from './dto/book-response.dto';
import { Controller, Get } from '@nestjs/common';
import { BookService } from './book.service';
import { Body, Post } from '@nestjs/common';


@Controller('books') // 이 컨트롤러로 들어오는 기본 주소: /books
export class BookController {
  // 주방장(BookService)을 주입받습니다.
  constructor(private readonly bookService: BookService) {}

  // HTTP GET 방식으로 /books 요청이 들어왔을 때 실행되는 핸들러
  @Get()
  async getBooks(): Promise<BookResponseDto[]> {
    return this.bookService.getAllBooks();
  }

  // POST http://localhost:3000/books
  @Post()
  async createBook(
    @Body(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: true,
      }),
    )
    dto: CreateBookDto,
  ): Promise<BookResponseDto> {
    return this.bookService.createBook(dto);
  }
}