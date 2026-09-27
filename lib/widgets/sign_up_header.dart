// sign_up_header.dart는 회원가입 화면 상단의 환영 안내 문구 영역을 구현함

import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다!\n간단한 정보를 입력하고 시작해보세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}