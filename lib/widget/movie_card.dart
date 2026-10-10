import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.rank, // 홈 화면 인기 영화의 순위 배지 (1, 2, 3...)
    this.showBadgeRating = false, // 영화 목록 화면의 우측 상단 평점 배지 (★ 4.8)
  });

  final Movie movie;
  final int? rank;
  final bool showBadgeRating;

  @override
  Widget build(BuildContext context) {
    final ratingValue = movie.rating > 0 ? movie.rating : 4.5;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.push('/movies/${movie.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 포스터 이미지 영역
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    movie.posterAsset,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkWhite,
                        child: const Center(
                          child: Icon(Icons.movie, color: AppColors.gray),
                        ),
                      );
                    },
                  ),
                ),

                // 좌측 상단 순위 배지 (홈 화면 인기 영화용)
                if (rank != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // 우측 상단 평점 배지 (목표 디자인 2번째 사진용)
                if (showBadgeRating)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$ratingValue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. 영화 제목
          Text(
            movie.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // 3. 하단 서브 정보
          // showBadgeRating이 true인 경우 (목록 화면): '년도 · 장르'
          // false인 경우 (홈 화면): '★ 평점'
          if (showBadgeRating)
            Text(
              '${movie.year} · ${movie.genre}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray,
                fontSize: 12,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '$ratingValue',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
