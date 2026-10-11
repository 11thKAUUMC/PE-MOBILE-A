import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Book } from './entities/book.entity';
import { Category } from './entities/category.entity';
import { CreateBookDto } from './dto/create-book.dto';

@Injectable()
export class BookRepository {
  constructor(
    @InjectRepository(Book)
    private readonly ormRepository: Repository<Book>,

    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}

  async findAll(): Promise<Book[]> {
    return this.ormRepository.find({
      relations: { category: true },
      order: { bookId: 'DESC' },
    });
  }

  async findCategoryById(categoryId: string): Promise<Category | null> {
    return this.categoryRepository.findOneBy({ categoryId });
  }

  async create(dto: CreateBookDto, category: Category): Promise<Book> {
    const book = this.ormRepository.create({
      title: dto.title,
      description: dto.description ?? null,
      category,
      isAvailable: true,
    });

    return this.ormRepository.save(book);
  }
}