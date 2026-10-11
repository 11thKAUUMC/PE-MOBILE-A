import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Book } from './entities/book.entity';
import { Category } from './entities/category.entity';
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { databaseProviders } from './database.provider';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { BookController } from './book.controller';
import { BookService } from './book.service';
import { BookRepository } from './book.repository';
import { RentalController } from './rental.controller';
import { RentalService } from './rental.service';
import { RentalRepository } from './rental.repository';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    TypeOrmModule.forRootAsync({
    inject: [ConfigService],
    useFactory: (config: ConfigService) => ({
      type: 'mysql',
      host: config.get<string>('DB_HOST', 'localhost'),
      port: Number(config.get('DB_PORT', 3306)),
      username: config.get<string>('DB_USER', 'root'),
      password: config.get<string>('DB_PASSWORD', ''),
      database: config.get<string>('DB_NAME', 'study'),
      autoLoadEntities: true,
      synchronize: false,
    }),
  }),

  TypeOrmModule.forFeature([Book, Category]),
  ],
  controllers: [
    AppController,
    BookController,
    RentalController
  ],
  providers: [
    ...databaseProviders,
    AppService,
    BookService,
    BookRepository,
    RentalService,
    RentalRepository
  ],
  exports: [...databaseProviders],
})
export class AppModule {}