import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widget/movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 추천 영화 (별빛 아래 우리)
    final featuredMovie = mockMovies.firstWhere(
      (m) => m.id == 1,
      orElse: () => mockMovies.first,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MovieLog',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.violet,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.black),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('오늘은 어떤\n영화를 볼까요?', style: AppTextStyles.titleLarge),
              const SizedBox(height: 20),

              // 메인 추천 영화 배너
              // 메인 추천 영화 배너 영역 (목표 디자인에 맞춘 수정 버전)
              GestureDetector(
                onTap: () => context.push('/movies/${featuredMovie.id}'),
                child: Container(
                  width: double.infinity, // 가로 폭을 전체로 넓힘
                  height: 420, // 높이를 적절히 늘려 내부 UI가 답답하지 않도록 조정
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(featuredMovie.posterAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85), // 하단 그라데이션 어둡게 처리
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 추천 신작 태그
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violet.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '추천 신작',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2. 영화 제목
                        Text(
                          featuredMovie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 3. 장르 및 상영시간 정보
                        Text(
                          '${featuredMovie.genre} · 120분',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. 상세보기 버튼 (목표 디자인 반영)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.violet,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '상세보기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('인기 영화', style: AppTextStyles.titleMedium),
                  TextButton(
                    onPressed: () => context.go('/movies'),
                    child: const Text(
                      '전체보기 >',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 인기 영화 가로 스크롤 (ListView.builder 활용)
              SizedBox(
                height: 220, // 높이를 적절히 조절
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockMovies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final movie = mockMovies[index];
                    return SizedBox(
                      width: 130,
                      child: MovieCard(
                        movie: movie,
                        rank: index + 1, // 1, 2, 3... 순위 전달
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
