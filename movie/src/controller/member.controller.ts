import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { LoginMember } from '../decorator/login-member.decorator';
import { MemberUpdateRequestDto } from '../dto/member-update-request.dto';
import { AuthGuard } from '../guard/auth.guard';
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

  @Get('me')
  @UseGuards(AuthGuard)
  async getMyInfo(@LoginMember() memberId: number) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '회원 정보를 조회했습니다.',
      result: await this.memberService.getMyInfo(memberId),
    };
  }

  @Patch('me')
  @UseGuards(AuthGuard)
  async updateMyInfo(
    @LoginMember() memberId: number,
    @Body() dto: MemberUpdateRequestDto,
  ) {
    return {
      isSuccess: true,
      code: 'COMMON200',
      message: '회원 정보를 수정했습니다.',
      result: await this.memberService.updateMyInfo(memberId, dto),
    };
  }
}
