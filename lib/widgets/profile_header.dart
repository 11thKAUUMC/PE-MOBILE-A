import 'package:flutter/material.dart';

import '../theme/week06_style.dart';
import '../data/models/member_info.dart';
import '../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.member});

  final MemberInfo member;

  @override
  Widget build(BuildContext context) {
    final date = member.createdAt.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.violet, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/profile_movielog.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.42),
            ),
          ),
        ),
        const SizedBox(height: 19),
        Text(
          member.nickname,
          style: Week06Style.text(20, weight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '${date.year}.$month.$day 가입',
          style: Week06Style.text(12, color: Week06Style.muted),
        ),
        const SizedBox(height: 4),
        Text(
          member.email,
          style: Week06Style.text(14, color: Week06Style.muted),
        ),
      ],
    );
  }
}
