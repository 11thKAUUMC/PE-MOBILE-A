import {
  IsByteLength,
  IsEmail,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';

export class CreateMemberDto {
  @IsEmail({}, { message: '올바른 이메일 형식이 아닙니다.' })
  @MaxLength(254)
  email: string;

  @IsString()
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$/, {
    message:
      '비밀번호는 대문자/소문자/숫자/특수문자를 포함한 8자 이상이어야 합니다.',
  })
  @IsByteLength(8, 72, {
    message: '비밀번호는 UTF-8 기준 72바이트 이하여야 합니다.',
  })
  password: string;

  @IsString()
  @Matches(/\S/, { message: '닉네임을 입력해주세요.' })
  @Length(2, 12, { message: '닉네임은 2자 이상 12자 이하여야 합니다.' })
  nickname: string;
}
