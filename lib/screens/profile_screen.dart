import 'package:flutter/material.dart';

import '../widgets/profile_header.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              ProfileHeader(),
              SizedBox(height: 32),
              StatItem(label: '본 영화', value: '24'),
            ],
          ),
        ),
      ),
    );
  }
}
