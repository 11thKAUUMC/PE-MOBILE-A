import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieDetailInfo extends StatelessWidget {
  const MovieDetailInfo({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(movie.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 6),
          Text(
            '${movie.year} • ${movie.tags.take(2).join('/')} • '
            '${movie.runtimeMinutes}분',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGray),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in movie.tags)
                Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.inputFill,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
