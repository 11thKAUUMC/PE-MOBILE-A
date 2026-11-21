import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/week06_style.dart';
import '../widgets/movielog_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({
    super.key,
    this.sessionCheck = false,
    this.message,
    this.onRetry,
  });

  final bool sessionCheck;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Week06Style.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 32),
                  Text(sessionCheck ? 'FLUTTER 8주차' : 'FLUTTER 1주차'),
                  const SizedBox(height: 64),
                  SvgPicture.asset(
                    'assets/logos/movielog_logo.svg',
                    width: 72,
                    height: 72,
                    semanticsLabel: 'MovieLog 로고',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (sessionCheck)
                if (onRetry == null)
                  const CircularProgressIndicator(strokeWidth: 2)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        message ?? '로그인 상태를 확인하지 못했어요.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      MovieLogButton(label: '다시 시도', onPressed: onRetry),
                    ],
                  )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/register');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
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
