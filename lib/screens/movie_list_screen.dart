import 'package:flutter/material.dart';

import '../models/movie.dart';

import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';

import '../theme/app_colors.dart';
import '../widget/common_app_bar.dart';
import '../widget/movie_card.dart';
import '../widget/movie_state.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';
  final List<String> genres = ['전체', '드라마', 'SF', '스릴러'];

  final movieService = const FakeMovieService();
  final genrePreference = GenrePreference();

  late Future<List<Movie>> _moviesFuture;

  bool _isRestoringGenre = true;
  bool _isSavingGenre = false;

  @override
  void initState() {
    super.initState();

    _moviesFuture = movieService.fetchMovies();
    _restoreGenre();
  }

  Future<void> _restoreGenre() async {
    try {
      final savedGenre = await genrePreference.read();

      if (!mounted) return;

      setState(() {
        selectedGenre = genres.contains(savedGenre) ? savedGenre : '전체';
      });
    } catch (error) {
      debugPrint("장르 복원 실패: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isRestoringGenre = false;
        });
      }
    }
  }

  Future<void> _selectGenre(String genre) async {
    setState(() {
      selectedGenre = genre;
      _isSavingGenre = true;
    });

    try {
      await genrePreference.save(genre);
    } catch (error) {
      debugPrint('장르 저장 실패: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장르 선택을 저장하지 못했습니다. 다시 선택해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingGenre = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _moviesFuture = movieService.fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '영화'),
      body: Column(
        children: [
          SizedBox(
            height: 40,
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
                  showCheckmark: false,
                  selectedColor: AppColors.violet,
                  disabledColor: AppColors.darkWhite,
                  backgroundColor: AppColors.darkWhite,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),

                  shape: const StadiumBorder(side: BorderSide.none),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  onSelected: _isRestoringGenre || _isSavingGenre
                      ? null
                      : (selected) {
                          if (selected) {
                            setState(() {
                              _selectGenre(genre);
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
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (_isRestoringGenre ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }

                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                final movies = snapshot.data ?? const <Movie>[];

                final filteredMovies = selectedGenre == '전체'
                    ? movies
                    : movies
                          .where((movie) => movie.genre == selectedGenre)
                          .toList();

                if (filteredMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: filteredMovies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      return MovieCard(
                        movie: filteredMovies[index],
                        showBadgeRating:
                            true, // 우측 상단 ★ 4.8 배지 및 하단 '년도 · 장르' 적용
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
