import 'package:provider/provider.dart';

import '../data/services/rating_api_service.dart';
import '../data/session/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import '../models/movie.dart';
import '../widgets/tmdb_poster_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../theme/app_colors.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId, this.movie});

  final int? movieId;
  final Movie? movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double? myRating;
  bool isFavorite = false;

  Future<void> _rateMovie() async {
    final memberId = context.read<LearningMemberSession?>()?.memberId;
    final movie = widget.movie;
    if (memberId == null || movie == null || !movie.isTmdb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            memberId == null
                ? '회원가입 후 평점을 등록할 수 있습니다.'
                : 'TMDB 영화에서 평점을 등록해 주세요.',
          ),
          action: memberId == null
              ? SnackBarAction(
                  label: '회원가입',
                  onPressed: () => context.push('/signup'),
                )
              : null,
        ),
      );
      return;
    }
    final vm = MovieDetailViewModel(
      context.read<RatingApiService>(),
      movie.id,
      memberId,
    );
    final rating = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .30),
      builder: (_) => RatingDialog(
        onSubmit: vm.createRating,
        onError: (message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
      ),
    );

    if (!mounted || rating == null) return;
    setState(() => myRating = rating.toDouble());
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('평점을 등록했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie ?? findMovieById(widget.movieId);
    final memberId = context.watch<LearningMemberSession?>()?.memberId;

    if (movie == null) {
      return const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.violet),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.violet,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.08,
              child: movie.isTmdb
                  ? TmdbPosterImage(posterPath: movie.posterPath)
                  : Image.asset(movie.posterAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${movie.year} · ${movie.tags.take(2).join('/')} ${movie.duration > 0 ? '· ${movie.duration}분' : ''}',
                    style: const TextStyle(color: AppColors.gray, fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.averageRating,
                        itemCount: 5,
                        itemSize: 25,
                        itemBuilder: (_, _) =>
                            const Icon(Icons.star, color: AppColors.violet),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${movie.averageRating.toStringAsFixed(1)} / 5',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: const Color(0xFFE9E5EE),
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시놉시스',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    movie.synopsis,
                    style: const TextStyle(fontSize: 16, height: 1.8),
                  ),
                  if (myRating != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      '내 평점 ${myRating!.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppColors.violet,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => isFavorite = !isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  label: const Text('즐겨찾기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: memberId == null
                    ? TextButton(
                        onPressed: () => context.push('/signup'),
                        child: const Text('평점을 남기려면 회원가입'),
                      )
                    : ElevatedButton.icon(
                        onPressed: movie.isTmdb ? _rateMovie : null,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('평점 남기기'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
