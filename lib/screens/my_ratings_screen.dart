import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(title: '내가 등록한 평점', onBack: () => context.pop()),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('평점을 불러오는 중'),
                  ],
                ),
              );

            case MyRatingsLoadStatus.empty:
              return const Center(child: Text('등록된 평점이 없습니다.'));

            case MyRatingsLoadStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.message ?? '평점을 불러오지 못했습니다.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      MovieLogButton(
                        label: '다시 시도',
                        onPressed: () => viewModel.load(),
                      ),
                    ],
                  ),
                ),
              );

            case MyRatingsLoadStatus.success:
              return Column(
                children: [
                  if (viewModel.message != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        viewModel.message!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: viewModel.ratings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _RatingCard(entry: viewModel.ratings[index]);
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.entry});

  final RatingWithMovie entry;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie;
    final posterPath = movie?.posterPath;
    final hasPoster = posterPath != null && posterPath.isNotEmpty;

    final date = rating.createdAt.toLocal();
    final dateText =
        '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.disabled, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 90,
              height: 135,
              child: hasPoster
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _posterPlaceholder(),
                    )
                  : _posterPlaceholder(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? '영화 #${rating.movieId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '별점 ${rating.score} / 5',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rating.comment != null) ...[
                  const SizedBox(height: 10),
                  Text(rating.comment!),
                ],
                if (!hasPoster) ...[
                  const SizedBox(height: 10),
                  const Text('포스터 정보 없음', style: TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 10),
                Text(
                  dateText,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      color: AppColors.disabled,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: Colors.white, size: 32),
    );
  }
}
