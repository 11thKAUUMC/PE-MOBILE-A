import 'package:flutter/material.dart';

import '../theme/week06_style.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('환영합니다!', style: Week06Style.text(17, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          '간단한 정보만 입력하고 시작해보세요.',
          style: Week06Style.text(14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
