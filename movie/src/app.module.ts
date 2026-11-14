import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './controller/auth.controller';
import { AuthService } from './service/auth.service';
import { AuthGuard } from './guard/auth.guard';
import { Member } from './entity/member.entity';
import { MemberController } from './controller/member.controller';
import { MemberService } from './service/member.service';
import { Rating } from './entity/rating.entity';
import { RatingController } from './controller/rating.controller';
import { RatingService } from './service/rating.service';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        const expiresIn = Number(
          config.get<string>('JWT_ACCESS_EXPIRATION') ?? 3600,
        );
        if (!secret || secret.length < 32) {
          throw new Error('JWT_SECRET must be at least 32 characters');
        }
        if (!Number.isSafeInteger(expiresIn) || expiresIn < 1) {
          throw new Error(
            'JWT_ACCESS_EXPIRATION must be a positive integer in seconds',
          );
        }
        return {
          secret,
          signOptions: { algorithm: 'HS256' as const, expiresIn },
          verifyOptions: { algorithms: ['HS256' as const] },
        };
      },
    }),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT) || 3306,
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      autoLoadEntities: true,
      synchronize: false,
    }),
    TypeOrmModule.forFeature([Member, Rating]),
  ],
  controllers: [MemberController, RatingController, AuthController],
  providers: [MemberService, RatingService, AuthService, AuthGuard],
})
export class AppModule {}
