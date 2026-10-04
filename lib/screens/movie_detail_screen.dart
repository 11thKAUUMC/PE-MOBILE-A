import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widget/common_app_bar.dart';
import '../widget/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final String? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.movieId ?? '');
    final movie = findMovieById(id);

    if (movie == null) {
      return Scaffold(
        appBar: CommonAppBar(title: '영화 상세', onBack: () => context.pop()),
        body: const Center(child: Text('존재하지 않는 영화입니다.')),
      );
    }

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
                    child: Image.asset(
                      movie.posterAsset,
                      width: double.infinity,
                      fit: BoxFit.cover, // 좌우/상하 꽉 차게 채움
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.darkWhite,
                        child: const Icon(
                          Icons.movie,
                          size: 50,
                          color: AppColors.gray,
                        ),
                      ),
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
                          '${movie.year} · ${movie.genre} · ${movie.runtime}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 12),

                        // 3. 별점 (보라색 별 색상 및 평가 수 표기)
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: movie.rating > 0 ? movie.rating : 4.5,
                              itemCount: 5,
                              itemSize: 22,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star_rounded,
                                color: AppColors.violet,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${movie.rating > 0 ? movie.rating : 4.5}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${movie.ratingCount})',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 4. 태그 칩
                        Wrap(
                          spacing: 8,
                          children: movie.tags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              backgroundColor: AppColors.darkWhite,
                              elevation: 0,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          }).toList(),
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
                          movie.description ?? '',
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
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.violet),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 삭제되었습니다.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.bookmark
                            : Icons.bookmark_border_rounded,
                        color: AppColors.violet,
                        size: 20,
                      ),
                      label: Text(
                        '즐겨찾기',
                        style: TextStyle(
                          color: AppColors.violet,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        final selectedRating = await showDialog<double>(
                          context: context,
                          builder: (dialogContext) => const RatingDialog(),
                        );

                        if (selectedRating != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$selectedRating점 평점이 등록되었습니다!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 20),
                      label: const Text(
                        '평점 남기기',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
