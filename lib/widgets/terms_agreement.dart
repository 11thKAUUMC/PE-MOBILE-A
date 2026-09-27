// terms_agreement.dart는 화면 하단의 필수 약관 동의 Checkbox 영역을 구현함

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Checkbox(
            value: value,
            activeColor: AppColors.violet,
            onChanged: (value) => onChanged(value ?? false),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '필수 약관에 동의합니다',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}