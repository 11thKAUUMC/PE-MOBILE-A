import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 32),
                alignment: Alignment.center,
                child: const EditProfileButton(),
              ),
              ProfileStats(),
              const SizedBox(height: 32),
              const FavoriteGenres(),
            ],
          ),
        ),
      ),
    );
  }
}
