import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '이미 계정이 있나요?  ',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGray),
        children: const [
          TextSpan(
            text: '로그인',
            style: TextStyle(
              color: AppColors.violet,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
