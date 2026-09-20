import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'FLUTTER 1주차',
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(height: 72),
                  SvgPicture.asset(
                    'assets/logos/movielog_logo.svg',
                    width: 72,
                    height: 72,
                    semanticsLabel: 'MovieLog 로고',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: AppColors.violet,
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
