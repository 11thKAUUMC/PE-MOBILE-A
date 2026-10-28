import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_text_styles.dart';
import '../view_models/movie_home_view_model.dart';
import '../widgets/common_app_bar.dart';
import 'featured_movie_card.dart';
import 'popular_movies_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'MovieLog',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: '검색',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MovieHomeViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.status) {
            MovieHomeLoadStatus.idle ||
            MovieHomeLoadStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            MovieHomeLoadStatus.error => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viewModel.message ?? '인기 영화를 불러오지 못했어요.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<MovieHomeViewModel>().loadPopular(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
            MovieHomeLoadStatus.empty => const Center(
              child: Text('표시할 인기 영화가 없어요.'),
            ),
            MovieHomeLoadStatus.success => SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '오늘은 어떤\n영화를 볼까요?',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FeaturedMovieCard(
                      movie: viewModel.popularMovies.first,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PopularMoviesSection(
                    movies: viewModel.popularMovies.length > 1
                        ? viewModel.popularMovies.sublist(1)
                        : const [],
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
