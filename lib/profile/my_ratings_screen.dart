import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>(
      builder: (context, viewModel, _) {
        return PopScope(
          canPop: !viewModel.isDeletingSelected,
          child: Scaffold(
            appBar: CommonAppBar(
              title: '내가 등록한 평점',
              centerTitle: true,
              onBack: viewModel.isDeletingSelected
                  ? null
                  : () => context.pop(),
              actions: [
                if (viewModel.status == MyRatingsLoadStatus.success ||
                    viewModel.status == MyRatingsLoadStatus.empty)
                  TextButton(
                    onPressed: viewModel.isDeletingSelected
                        ? null
                        : () {
                            if (viewModel.isEditMode) {
                              viewModel.exitEditMode();
                            } else {
                              viewModel.enterEditMode();
                            }
                          },
                    child: Text(viewModel.isEditMode ? '취소' : '편집'),
                  ),
              ],
            ),
            body: SafeArea(
              child: LoadingOverlay(
                isLoading: viewModel.isDeletingSelected,
                child: Column(
                  children: [
                    if (viewModel.isEditMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${viewModel.selectedRatingIds.length}개 선택됨',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                    if (viewModel.refreshWarning != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              viewModel.refreshWarning!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            TextButton(
                              onPressed: viewModel.load,
                              child: const Text('조회 다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildBody(context, viewModel)),
                    if (viewModel.isEditMode)
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: MovieLogButton(
                            label:
                                '선택한 ${viewModel.selectedRatingIds.length}개 삭제',
                            width: double.infinity,
                            onPressed: viewModel.selectedRatingIds.isEmpty ||
                                    viewModel.isDeletingSelected
                                ? null
                                : () => onDeleteSelectedPressed(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
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
        isEditMode: viewModel.isEditMode,
        selectedRatingIds: viewModel.selectedRatingIds,
      ),
    };
  }
}

Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RatingDialog(
      initialScore: rating.score,
      initialComment: rating.comment,
      onSubmit: (score, comment) => context.read<MyRatingsViewModel>().updateRating(
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      ),
    ),
  );

  if (!context.mounted || saved != true) return;
}

Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteRatingDialog(
      onConfirm: () =>
          context.read<MyRatingsViewModel>().deleteRating(rating.ratingId),
    ),
  );
  if (!context.mounted || confirmed != true) return;
}

Future<void> onDeleteSelectedPressed(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('선택한 평점을 삭제할까요?'),
      content: const Text('삭제한 평점은 복구할 수 없습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('삭제'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final viewModel = context.read<MyRatingsViewModel>();
  await viewModel.deleteSelectedRatings();
  if (!context.mounted) return;
  if (viewModel.message != null && viewModel.message!.contains('삭제하지')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(viewModel.message!)),
    );
  }
}

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
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
  const _SuccessState({
    required this.ratings,
    required this.isEditMode,
    required this.selectedRatingIds,
    this.message,
  });

  final List<RatingWithMovie> ratings;
  final bool isEditMode;
  final Set<int> selectedRatingIds;
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
        return _RatingCard(
          entry: entry,
          isEditMode: isEditMode,
          isSelected: selectedRatingIds.contains(entry.rating.ratingId),
        );
      },
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.entry,
    required this.isEditMode,
    required this.isSelected,
  });

  final RatingWithMovie entry;
  final bool isEditMode;
  final bool isSelected;

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
          if (isEditMode)
            Checkbox(
              value: isSelected,
              onChanged: (_) => context
                  .read<MyRatingsViewModel>()
                  .toggleSelection(rating.ratingId),
            )
          else
            Column(
              children: [
                IconButton(
                  tooltip: '수정',
                  onPressed: () => onEditPressed(context, rating),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: '삭제',
                  onPressed: () => onDeletePressed(context, rating),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
