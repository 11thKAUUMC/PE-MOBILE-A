import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieDetailInfo extends StatelessWidget {
  const MovieDetailInfo({super.key, required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    final meta = [
      ?movie.releaseYear,
      'TMDB #${movie.id}',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(movie.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 6),
          Text(
            meta,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGray),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              RatingBarIndicator(
                rating: (movie.voteAverage / 2).clamp(0, 5),
                itemCount: 5,
                itemSize: 20,
                itemBuilder: (context, index) {
                  return const Icon(Icons.star, color: AppColors.violet);
                },
              ),
              const SizedBox(width: 8),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (movie.genreIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genreId in movie.genreIds)
                  Chip(
                    label: Text('장르 $genreId'),
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
        ],
      ),
    );
  }
}
