import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Consumer<MyRatingsViewModel>(
          builder: (context, viewModel, _) {
            return switch (viewModel.status) {
              MyRatingsLoadStatus.idle || MyRatingsLoadStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              MyRatingsLoadStatus.empty => const _EmptyState(),
              MyRatingsLoadStatus.error => _ErrorState(
                message: viewModel.message ?? '평점을 불러오지 못했습니다.',
                onRetry: viewModel.load,
              ),
              MyRatingsLoadStatus.success => _SuccessState(
                ratings: viewModel.ratings,
                message: viewModel.message,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: AppColors.gray),
          SizedBox(height: 12),
          Text('아직 등록한 평점이 없습니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.ratings, this.message});

  final List<RatingWithMovie> ratings;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: ratings.length + (message == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (message != null && index == 0) {
          return Text(
            message!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray),
          );
        }
        final entry = ratings[message == null ? index : index - 1];
        return _RatingCard(entry: entry);
      },
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
    final title = movie?.title ?? '영화 정보를 불러올 수 없음';
    final local = rating.createdAt.toLocal();
    final dateText =
        '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TmdbPosterImage(
              posterPath: movie?.posterPath,
              width: 72,
              height: 108,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '영화 ID ${rating.movieId}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Text('${rating.score}점', style: AppTextStyles.bodyMedium),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(comment, style: AppTextStyles.bodySmall),
                ],
                const SizedBox(height: 6),
                Text(dateText, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
