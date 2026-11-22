import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/tmdb_poster_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rating_dialog.dart';

import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final movie = context.read<MovieDetailViewModel>().movie;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(
        title: 'Cinema Archive',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 스크롤 가능한 메인 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 화면 가로 폭에 완전히 꽉 차는 이미지 (AspectRatio 제거)
                  SizedBox(
                    width: double.infinity,
                    height: 280, // 원하는 세로 높이에 맞추어 조정
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return TmdbPosterImage(
                          posterPath: movie.posterPath,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. 제목 & 기본 정보
                        Text(movie.title, style: AppTextStyles.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (DateTime.tryParse(movie.releaseDate ?? '') !=
                                null)
                              '${DateTime.parse(movie.releaseDate!).year}년 개봉',
                            'TMDB 평점 ${movie.voteAverage.toStringAsFixed(1)} / 10',
                          ].join(' · '),
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 12),

                        // 3. 별점 (보라색 별 색상 및 평가 수 표기)
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: (movie.voteAverage / 2)
                                  .clamp(0.0, 5.0)
                                  .toDouble(),
                              itemCount: 5,
                              itemSize: 22,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star_rounded,
                                color: AppColors.violet,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${movie.voteAverage.toStringAsFixed(1)} / 10',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 5. 구분선 1
                        const Divider(thickness: 1, color: AppColors.outline),
                        const SizedBox(height: 20),

                        // 6. '시놉시스' 타이틀 & 긴 줄거리 본문
                        const Text(
                          '시놉시스',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          movie.overview.trim().isEmpty
                              ? '줄거리 정보가 없어요.'
                              : movie.overview,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 7. 구분선 2
                        const Divider(thickness: 1, color: AppColors.outline),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼 바 (즐겨찾기 / 평점 남기기)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.warmWhite,
              border: Border(
                top: BorderSide(color: AppColors.outline, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        final saved = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => RatingDialog(
                            onSubmit: (score, comment) async {
                              final viewModel = context
                                  .read<MovieDetailViewModel>();

                              await viewModel.createRating(
                                score: score,
                                comment: comment,
                              );

                              if (viewModel.submitStatus !=
                                  SubmitStatus.success) {
                                throw StateError(
                                  viewModel.submitMessage ?? '저장에 실패했습니다.',
                                );
                              }
                            },
                          ),
                        );

                        if (!context.mounted || saved != true) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('평점을 등록했어요.')),
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 20),
                      label: Consumer<MovieDetailViewModel>(
                        builder: (context, viewModel, child) {
                          final rating = viewModel.createdRating;

                          return Text(
                            rating == null ? '평점 남기기' : '내 평점 ${rating.score}점',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
