import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                '로그인',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.violet,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
