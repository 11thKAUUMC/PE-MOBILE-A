import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
} from 'typeorm';
import { Book } from './book.entity';

@Entity('category')
export class Category {
  @PrimaryGeneratedColumn({
    name: 'category_id',
    type: 'bigint',
  })
  categoryId: string;

  @Column({ type: 'varchar', length: 50 })
  name: string;

  @OneToMany(() => Book, (book) => book.category)
  books: Book[];
}