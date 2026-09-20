import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.violet,
            backgroundColor: AppColors.warmWhite,
            side: const BorderSide(color: AppColors.violet),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          ),
          child: Text(
            '프로필 수정',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.violet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
