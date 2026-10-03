import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  @override
  Widget build(BuildContext context) {
    const genres = ['드라마', 'SF', '애니메이션'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('선호하는 장르', style: AppTextStyles.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final genre in genres)
              Chip(
                label: Text(
                  genre,
                  style: AppTextStyles.statLabel.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: AppColors.genreChip,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        ),
      ],
    );
  }
}
