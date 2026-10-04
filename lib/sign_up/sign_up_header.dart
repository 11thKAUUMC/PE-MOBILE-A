import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key, this.showTitle = false});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.darkGray,
    );

    if (!showTitle) {
      return Text(
        '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
        textAlign: TextAlign.center,
        style: subtitleStyle,
      );
    }

    return Column(
      children: [
        Text(
          '회원가입',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.violet),
        ),
        const SizedBox(height: 8),
        Text('MovieLog에 오신 것을 환영합니다!', style: subtitleStyle),
      ],
    );
  }
}
