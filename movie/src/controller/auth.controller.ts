import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { LoginRequestDto } from '../dto/login-request.dto';
import { AuthService } from '../service/auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginRequestDto) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '로그인에 성공했습니다.',
      result: await this.authService.login(dto),
    };
  }
}
