import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import 'edit_profile_button.dart';
import 'favorite_genres.dart';
import 'profile_header.dart';
import 'profile_stat.dart';
import 'profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _stats = [
    ProfileStat(label: '본 영화', value: '342'),
    ProfileStat(label: '평점', value: '4.2'),
    ProfileStat(label: '즐겨찾기', value: '58'),
  ];

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeader(
                nickname: '무비러버',
                bio: '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
                imagePath: 'assets/images/profile/profile_movielog.jpg',
              ),
              const SizedBox(height: 24),
              const EditProfileButton(),
              const SizedBox(height: 32),
              const ProfileStats(stats: _stats),
              const SizedBox(height: 32),
              const FavoriteGenres(genres: _genres),
              const SizedBox(height: 32),
              Text('내 활동', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '내가 등록한 평점',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my/ratings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
