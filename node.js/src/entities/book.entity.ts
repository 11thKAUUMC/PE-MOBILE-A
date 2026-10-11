import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Category } from './category.entity';

@Entity('book')
export class Book {
  @PrimaryGeneratedColumn({
    name: 'book_id',
    type: 'bigint',
  })
  bookId: string;

  @Column({ type: 'varchar', length: 100 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({
    name: 'is_available',
    type: 'boolean',
    default: true,
  })
  isAvailable: boolean;

  @ManyToOne(() => Category, (category) => category.books, {
    nullable: false,
  })
  @JoinColumn({
    name: 'category_id',
    referencedColumnName: 'categoryId',
  })
  category: Category;
}