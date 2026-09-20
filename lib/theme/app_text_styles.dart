import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
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
  );

  static const statLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.violet,
  );
}
