import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/submit_status.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';
import 'movie_detail_actions.dart';
import 'movie_detail_header.dart';
import 'movie_detail_info.dart';
import 'movie_synopsis.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

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
    final viewModel = context.read<MovieDetailViewModel>();
    if (!viewModel.canRate) {
      _showSnackBar('먼저 로그인해 주세요.');
      return;
    }

    var savedScore = 0;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
          savedScore = score;
        },
      ),
    );

    if (!mounted || saved != true) return;

    setState(() => _myRating = savedScore.toDouble());
    _showSnackBar(
      '평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;
    final canRate = viewModel.canRate;

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
      body: _MovieDetailBody(movie: movie),
      bottomNavigationBar: MovieDetailActions(
        isFavorite: _isFavorite,
        myRating: _myRating,
        onFavoritePressed: _toggleFavorite,
        onRatingPressed: canRate
            ? _openRatingDialog
            : () => _showSnackBar('먼저 로그인해 주세요.'),
      ),
    );
  }
}

class _MovieDetailBody extends StatelessWidget {
  const _MovieDetailBody({required this.movie});

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
