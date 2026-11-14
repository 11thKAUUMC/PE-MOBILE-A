class CreateMemberRequest {
  const CreateMemberRequest({
    required this.nickname,
    required this.email,
    required this.password,
  });

  final String nickname;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    'nickname': nickname.trim(),
    'email': email.trim(),
    'password': password,
  };
}

class SignUpResult {
  SignUpResult.fromJson(Map<String, dynamic> json)
    : memberId = json['memberId'] as int,
      email = json['email'] as String,
      nickname = json['nickname'] as String;

  final int memberId;
  final String email;
  final String nickname;
}
