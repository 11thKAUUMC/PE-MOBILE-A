import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/movie_state.dart';
import '../widgets/tmdb_poster_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieHomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MovieLog',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.violet,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.black),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('오늘은 어떤\n영화를 볼까요?', style: AppTextStyles.titleLarge),
              const SizedBox(height: 20),
              ..._buildMovieContent(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMovieContent(
    BuildContext context,
    MovieHomeViewModel viewModel,
  ) {
    switch (viewModel.status) {
      case MovieHomeLoadStatus.idle:
      case MovieHomeLoadStatus.loading:
        return [const SizedBox(height: 300, child: MovieListLoading())];

      case MovieHomeLoadStatus.error:
        return [
          SizedBox(
            height: 300,
            child: MovieListError(
              onRetry: () {
                context.read<MovieHomeViewModel>().loadPopular();
              },
            ),
          ),
        ];

      case MovieHomeLoadStatus.empty:
        return [const SizedBox(height: 300, child: MovieListEmpty())];

      case MovieHomeLoadStatus.success:
        final movies = viewModel.popularMovies;

        // 성공 상태라도 목록이 비어 있으면 첫 요소에 접근하지 않는다.
        if (movies.isEmpty) {
          return [const SizedBox(height: 300, child: MovieListEmpty())];
        }

        final featuredMovie = movies.first;

        return [
          _FeaturedMovieBanner(movie: featuredMovie),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('인기 영화', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () => context.go('/movies'),
                child: const Text(
                  '전체보기 >',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 130,
                  child: _PopularMovieCard(
                    movie: movies[index],
                    rank: index + 1,
                  ),
                );
              },
            ),
          ),
        ];
    }
  }
}

class _FeaturedMovieBanner extends StatelessWidget {
  const _FeaturedMovieBanner({required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    final releaseDate = DateTime.tryParse(movie.releaseDate ?? '');

    final subtitle = [
      if (releaseDate != null) '${releaseDate.year}년 개봉',
      'TMDB ★ ${movie.voteAverage.toStringAsFixed(1)}',
    ].join(' · ');

    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}', extra: movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          height: 420,
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '인기 영화 추천',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '상세보기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularMovieCard extends StatelessWidget {
  const _PopularMovieCard({required this.movie, required this.rank});

  final TmdbMovieDto movie;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TmdbPosterImage(
                        posterPath: movie.posterPath,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
