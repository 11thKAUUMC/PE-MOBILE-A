import 'package:flutter/material.dart';

import '../theme/week06_style.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/movielog_button.dart';
import '../view_models/auth_view_model.dart';

import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;
    return Scaffold(
      backgroundColor: Week06Style.background,
      appBar: AppBar(
        backgroundColor: Week06Style.background,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: member == null,
        actions: [
          TextButton(onPressed: auth.logout, child: const Text('로그아웃')),
        ],
        title: Text(
          '내 프로필',
          style: Week06Style.text(
            22,
            color: AppColors.violet,
            weight: FontWeight.w700,
          ),
        ),
      ),
      body: member == null || auth.memberStatus != MemberLoadStatus.success
          ? Center(
              child: auth.memberStatus == MemberLoadStatus.error
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('내 정보를 불러오지 못했어요.'),
                        const SizedBox(height: 24),
                        MovieLogButton(
                          label: '다시 시도',
                          width: 218,
                          onPressed: () => auth.loadMember(force: true),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(strokeWidth: 2),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(member: member),
                    Container(
                      margin: const EdgeInsets.only(top: 28, bottom: 32),
                      alignment: Alignment.center,
                      child: EditProfileButton(
                        onPressed: () => context.push('/my/profile/edit'),
                      ),
                    ),
                    ProfileStats(),
                    const SizedBox(height: 25),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFD6C9E8),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push('/my/ratings'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 20.5,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '내가 등록한 평점',
                                  style: Week06Style.text(
                                    16,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 24,
                                color: AppColors.violet,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const FavoriteGenres(),
                  ],
                ),
              ),
            ),
    );
  }
}
