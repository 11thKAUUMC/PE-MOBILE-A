import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import 'movie_detail_header.dart';
import 'movie_detail_info.dart';
import 'movie_synopsis.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(int.tryParse(movieId));

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Cinema Archive',
        centerTitle: true,
        titleStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.violet,
          fontWeight: FontWeight.w700,
        ),
        onBack: () => _goBack(context),
      ),
      body: movie == null ? const _MovieNotFound() : _MovieDetailBody(movie),
    );
  }
}

class _MovieDetailBody extends StatelessWidget {
  const _MovieDetailBody(this.movie);

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MovieDetailHeader(posterAsset: movie.posterAsset),
          MovieDetailInfo(movie: movie),
          const Divider(height: 1, color: AppColors.outline),
          MovieSynopsis(synopsis: movie.synopsis),
        ],
      ),
    );
  }
}

class _MovieNotFound extends StatelessWidget {
  const _MovieNotFound();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('영화 정보를 찾을 수 없습니다.', style: AppTextStyles.bodyMedium),
    );
  }
}
