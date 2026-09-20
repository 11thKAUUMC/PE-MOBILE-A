import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.warmWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      primary: AppColors.violet,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.lavender,
      onPrimaryContainer: AppColors.violet,
      surface: AppColors.warmWhite,
      onSurface: AppColors.black,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.black,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.warmWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet,
        foregroundColor: AppColors.white,
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: const StadiumBorder(),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.lavender,
      selectedColor: AppColors.lavender,
      disabledColor: AppColors.lavender,
      side: BorderSide.none,
      shape: StadiumBorder(),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.violet,
      ),
    ),
  );
}
