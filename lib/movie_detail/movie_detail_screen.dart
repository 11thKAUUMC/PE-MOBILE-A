import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';
import 'movie_detail_actions.dart';
import 'movie_detail_header.dart';
import 'movie_detail_info.dart';
import 'movie_synopsis.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    _showSnackBar(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.');
  }

  Future<void> _openRatingDialog() async {
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => RatingDialog(initialRating: _myRating ?? 0),
    );
    if (rating == null || !mounted) return;

    setState(() => _myRating = rating);
    _showSnackBar('${rating.toStringAsFixed(1)}점으로 평점을 남겼습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(int.tryParse(widget.movieId));

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Cinema Archive',
        centerTitle: true,
        titleStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.violet,
          fontWeight: FontWeight.w700,
        ),
        onBack: _goBack,
      ),
      body: movie == null ? const _MovieNotFound() : _MovieDetailBody(movie),
      bottomNavigationBar: movie == null
          ? null
          : MovieDetailActions(
              isFavorite: _isFavorite,
              myRating: _myRating,
              onFavoritePressed: _toggleFavorite,
              onRatingPressed: _openRatingDialog,
            ),
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
