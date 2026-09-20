import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.violet, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_movielog.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('무비러버', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            '매주 주말엔 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
