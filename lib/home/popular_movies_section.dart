import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/movie_card.dart';

class PopularMoviesSection extends StatelessWidget {
  const PopularMoviesSection({super.key, required this.movies});

  static const _cardWidth = 140.0;
  static const _listHeight = _cardWidth / MovieCard.posterAspectRatio + 64;

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('인기 영화', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () => context.go('/movies'),
                style: TextButton.styleFrom(foregroundColor: AppColors.violet),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('전체보기'),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: _cardWidth,
                child: MovieCard(movie: movies[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
