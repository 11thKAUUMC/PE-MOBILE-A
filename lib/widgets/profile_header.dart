import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/profile_movielog.jpg',
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text('무비러버', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '좋아하는 영화를 기록하고 있어요',
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SvgPicture.asset(
          'assets/icons/movie.svg',
          width: 24,
          height: 24,
          semanticsLabel: '영화 아이콘',
        ),
      ],
    );
  }
}
