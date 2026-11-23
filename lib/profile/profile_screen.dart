import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/member_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';
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

  String _formatJoinedAt(DateTime createdAt) {
    final local = createdAt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y.$m.$d 가입';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;
    final memberStatus = auth.memberStatus;

    return Scaffold(
      appBar: CommonAppBar(
        title: '내 프로필',
        actions: [
          TextButton(
            onPressed: auth.storageCleanupInProgress
                ? null
                : () => auth.logout(),
            child: const Text('로그아웃'),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, auth, member, memberStatus),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthViewModel auth,
    MemberInfo? member,
    MemberLoadStatus memberStatus,
  ) {
    if (memberStatus == MemberLoadStatus.loading ||
        (member == null && memberStatus != MemberLoadStatus.error)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (memberStatus == MemberLoadStatus.error || member == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                auth.message ?? '내 정보를 불러오지 못했어요.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              MovieLogButton(
                label: '다시 시도',
                onPressed: () => auth.loadMember(force: true),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            nickname: member.nickname,
            bio: member.email,
            joinedAt: _formatJoinedAt(member.createdAt),
            imagePath: 'assets/images/profile/profile_movielog.jpg',
          ),
          const SizedBox(height: 24),
          EditProfileButton(
            enabled: true,
            onPressed: () => context.push('/my/profile/edit'),
          ),
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
            ),
            subtitle: Text(
              '이번 세션에서 등록한 평점만 표시됩니다.',
              style: AppTextStyles.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/my/ratings'),
          ),
        ],
      ),
    );
  }
}
