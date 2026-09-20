import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.nickname,
    required this.bio,
    this.imagePath,
  });

  final String nickname;
  final String bio;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.lavender,
              width: 2,
            ),
          ),
          child: hasImage
              ? ClipOval(
                  child: Image.asset(
                    imagePath!,
                    width: 112,
                    height: 112,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.violet,
                  child: SvgPicture.asset(
                    'assets/icons/person.svg',
                    width: 48,
                    height: 48,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: '기본 프로필 아이콘',
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Text(
          nickname,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
