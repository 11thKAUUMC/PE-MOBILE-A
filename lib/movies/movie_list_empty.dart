import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_outlined, size: 48, color: AppColors.gray),
          SizedBox(height: 12),
          Text('조건에 맞는 영화가 없습니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
