import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const headlineSmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.3,
  );

  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
    height: 1.5,
  );

  static const statValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );

  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.gray,
    letterSpacing: 1.2,
  );
}
