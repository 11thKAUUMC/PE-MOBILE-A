import 'package:flutter/material.dart';

import '../theme/week06_style.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Week06Style.background,
      appBar: AppBar(
        backgroundColor: Week06Style.background,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        title: Text(
          '내 프로필',
          style: Week06Style.text(
            22,
            color: AppColors.violet,
            weight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(),
              Container(
                margin: const EdgeInsets.only(top: 28, bottom: 32),
                alignment: Alignment.center,
                child: const EditProfileButton(),
              ),
              ProfileStats(),
              const SizedBox(height: 25),
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFD6C9E8), width: 1.5),
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
