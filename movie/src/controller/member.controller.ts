import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CreateMemberDto } from '../dto/create-member.dto';
import { MemberService } from '../service/member.service';

@Controller('members')
export class MemberController {
  constructor(private readonly memberService: MemberService) {}

  @Get('nickname/:nickname')
  checkNickname(@Param('nickname') nickname: string) {
    return this.memberService.checkNickname(nickname);
  }

  @Get('email/:email')
  checkEmail(@Param('email') email: string) {
    return this.memberService.checkEmail(email);
  }

  @Post()
  async signUp(@Body() dto: CreateMemberDto) {
    return {
      isSuccess: true,
      code: 'COMMON201',
      message: '회원가입에 성공했습니다.',
      result: await this.memberService.signUp(dto),
    };
  }
}
