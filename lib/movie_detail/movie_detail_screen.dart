import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';
import 'movie_detail_actions.dart';
import 'movie_detail_header.dart';
import 'movie_detail_info.dart';
import 'movie_synopsis.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.movie,
  });

  final String movieId;
  final TmdbMovieDto? movie;

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
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
    // 이후 자체 API 연동 시 CreateRatingRequest.movieId 로 전달할 TMDB id
    _showSnackBar(
      'movieId=${widget.movieId} · ${rating.toStringAsFixed(1)}점으로 평점을 남겼습니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final matchesId =
        movie != null && movie.id.toString() == widget.movieId;

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
      body: movie == null || !matchesId
          ? _MovieNotFound(movieId: widget.movieId)
          : _MovieDetailBody(movie),
      bottomNavigationBar: movie == null || !matchesId
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

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    final overview = movie.overview.trim().isEmpty
        ? '줄거리 정보가 없어요.'
        : movie.overview;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MovieDetailHeader(posterPath: movie.posterPath),
          MovieDetailInfo(movie: movie),
          const Divider(height: 1, color: AppColors.outline),
          MovieSynopsis(synopsis: overview),
        ],
      ),
    );
  }
}

class _MovieNotFound extends StatelessWidget {
  const _MovieNotFound({required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '영화 정보를 찾을 수 없습니다.\n(movieId: $movieId)',
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
