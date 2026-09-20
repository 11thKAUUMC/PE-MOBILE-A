import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({
    super.key,
    required this.genres,
  });

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선호하는 장르',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres
              .map(
                (genre) => Chip(
                  label: Text(
                    genre,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.lavender,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
