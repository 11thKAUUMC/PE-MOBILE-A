import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../theme/app_text_styles.dart';
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
      body: SingleChildScrollView(
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
              child: FeaturedMovieCard(movie: movies.first),
            ),
            const SizedBox(height: 32),
            PopularMoviesSection(movies: movies.skip(1).toList()),
          ],
        ),
      ),
    );
  }
}
