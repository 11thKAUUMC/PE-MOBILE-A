class MemberInfo {
  const MemberInfo({
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  final String email;
  final String nickname;
  final DateTime createdAt;

  factory MemberInfo.fromJson(Map<String, dynamic> json) => MemberInfo(
    email: json['email'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
