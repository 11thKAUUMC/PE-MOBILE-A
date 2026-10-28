import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/tmdb_poster_image.dart';

class FeaturedMovieCard extends StatelessWidget {
  const FeaturedMovieCard({super.key, required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 0.68,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return TmdbPosterImage(
                    posterPath: movie.posterPath,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  );
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: _FeaturedMovieContent(movie: movie),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedMovieContent extends StatelessWidget {
  const _FeaturedMovieContent({required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      ?movie.releaseYear,
      '평점 ${movie.voteAverage.toStringAsFixed(1)}',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.violet.withValues(alpha: 0.6),
            border: Border.all(
              color: AppColors.lavender.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '추천 신작',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          movie.title,
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/movies/${movie.id}', extra: movie),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56)),
            icon: const Icon(Icons.info),
            label: const Text(
              '상세보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
