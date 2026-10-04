abstract final class SignUpValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? nickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일을 입력해주세요.';
    if (!_emailPattern.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    return null;
  }
}
