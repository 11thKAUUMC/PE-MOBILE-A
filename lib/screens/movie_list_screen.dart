import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widget/common_app_bar.dart';
import '../widget/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '스릴러'];

  @override
  Widget build(BuildContext context) {
    // 선택한 장르에 맞춰 필터링
    final filteredMovies = selectedGenre == '전체'
        ? mockMovies
        : mockMovies.where((m) => m.genre == selectedGenre).toList();

    return Scaffold(
      appBar: const CommonAppBar(title: '영화'),
      body: Column(
        children: [
          // 장르 선택 Chip 목록 (ListView.separated)
          // 장르 선택 Chip 목록 (ListView.separated)
          SizedBox(
            height: 40, // 칩 높이 간격에 맞게 조정
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == selectedGenre;

                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  showCheckmark: false, // 1. 체크 아이콘(v) 제거
                  selectedColor: AppColors.violet, // 선택된 칩 배경색
                  disabledColor: AppColors.darkWhite,
                  backgroundColor:
                      AppColors.darkWhite, // 선택 안 된 칩 배경색 (연보라/연회색)
                  // 2. 글자 색상 제어
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),

                  // 3. 모서리를 완전 원형(알약 형태)으로 설정
                  shape: const StadiumBorder(
                    side: BorderSide.none, // 테두리선 제거
                  ),

                  // 여백 및 패딩 조정
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedGenre = genre;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 영화 목록 (GridView.builder)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: filteredMovies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: filteredMovies[index],
                    showBadgeRating: true, // 우측 상단 ★ 4.8 배지 및 하단 '년도 · 장르' 적용
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
