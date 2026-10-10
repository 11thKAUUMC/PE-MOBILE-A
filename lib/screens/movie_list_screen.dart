import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/movie_sort.dart';
import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';
import '../services/sort_preference.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const genres = ['전체', '드라마', '미스터리', 'SF', '액션', '로맨스', '스릴러'];
  String selectedGenre = '전체';
  final movieService = const FakeMovieService();
  final genrePreference = GenrePreference();
  final sortPreference = SortPreference();
  MovieSort selectedSort = MovieSort.original;
  bool _savingSort = false;
  bool _restoringGenre = true;
  bool _savingGenre = false;
  bool _refreshing = false;
  late Future<List<Movie>> _moviesFuture;

  Future<List<Movie>> _fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) {
    return movieService
        .fetchMovies(mode: mode)
        .timeout(const Duration(seconds: 3));
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = _loadInitialMovies();
  }

  Future<String> _readGenre() async {
    try {
      return await genrePreference.read();
    } catch (error) {
      debugPrint('장르 복원 실패: $error');
      return '전체';
    }
  }

  Future<List<Movie>> _loadInitialMovies() async {
    final results = await Future.wait<Object>([
      _fetchMovies(),
      _readGenre(),
      _readSort(),
    ]);
    if (!mounted) return results[0] as List<Movie>;

    final savedGenre = results[1] as String;
    setState(() {
      selectedGenre = genres.contains(savedGenre) ? savedGenre : '전체';
      selectedSort = results[2] as MovieSort;
      _restoringGenre = false;
    });
    return results[0] as List<Movie>;
  }

  Future<MovieSort> _readSort() async {
    try {
      return await sortPreference.read();
    } catch (error) {
      debugPrint('정렬 복원 실패: $error');
      return MovieSort.original;
    }
  }

  Future<void> _selectSort(MovieSort sort) async {
    setState(() {
      selectedSort = sort;
      _savingSort = true;
    });
    try {
      await sortPreference.save(sort);
    } catch (error) {
      debugPrint('정렬 저장 실패: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정렬 설정을 저장하지 못했습니다. 다시 선택해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingSort = false;
        });
      }
    }
  }

  Future<void> _selectGenre(String genre) async {
    setState(() {
      selectedGenre = genre;
      _savingGenre = true;
    });
    try {
      await genrePreference.save(genre);
    } catch (error) {
      debugPrint('장르 저장 실패: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장르 설정을 저장하지 못했습니다. 다시 선택해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingGenre = false;
        });
      }
    }
  }

  void _loadMovies(MovieLoadMode mode) {
    setState(() {
      _moviesFuture = _fetchMovies(mode: mode);
    });
  }

  void _retry() {
    _loadMovies(MovieLoadMode.success);
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    final future = _fetchMovies();
    setState(() {
      _refreshing = true;
      _moviesFuture = future;
    });
    try {
      await future;
    } catch (error) {
      // FutureBuilder가 오류 화면을 표시합니다.
      debugPrint('새로고침 실패: $error');
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '영화',
          style: TextStyle(
            color: AppColors.violet,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (kDebugMode)
            PopupMenuButton<MovieLoadMode>(
              tooltip: '스터디 상태 확인',
              icon: const Icon(Icons.science_outlined, color: AppColors.violet),
              onSelected: _restoringGenre ? null : _loadMovies,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: MovieLoadMode.success,
                  child: Text('Success 확인'),
                ),
                PopupMenuItem(
                  value: MovieLoadMode.empty,
                  child: Text('Empty 확인'),
                ),
                PopupMenuItem(
                  value: MovieLoadMode.failure,
                  child: Text('Error 확인'),
                ),
                PopupMenuItem(
                  value: MovieLoadMode.timeout,
                  child: Text('Timeout 확인 (3초)'),
                ),
              ],
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.violet),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  final genre = genres[index];

                  return ChoiceChip(
                    label: Text(genre),
                    selected: selectedGenre == genre,
                    selectedColor: AppColors.violet,
                    backgroundColor: const Color(0xFFE9E5EE),
                    labelStyle: TextStyle(
                      color: selectedGenre == genre
                          ? Colors.white
                          : AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: const StadiumBorder(side: BorderSide.none),
                    onSelected: _restoringGenre || _savingGenre
                        ? null
                        : (_) => _selectGenre(genre),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<MovieSort>(
                value: selectedSort,
                underline: const SizedBox.shrink(),
                items: MovieSort.values.map((sort) {
                  return DropdownMenuItem(value: sort, child: Text(sort.label));
                }).toList(),
                onChanged: _restoringGenre || _savingSort
                    ? null
                    : (sort) {
                        if (sort != null) _selectSort(sort);
                      },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !_refreshing) {
                    return const MovieListLoading();
                  }

                  if (snapshot.hasError) {
                    return MovieListError(
                      onRetry: _retry,
                      isTimeout: snapshot.error is TimeoutException,
                    );
                  }

                  final loadedMovies = snapshot.data ?? const <Movie>[];
                  final filteredMovies = selectedGenre == '전체'
                      ? loadedMovies
                      : loadedMovies
                            .where((movie) => movie.genre == selectedGenre)
                            .toList();

                  final sortedMovies = List<Movie>.of(filteredMovies);
                  if (selectedSort != MovieSort.original) {
                    sortedMovies.sort((a, b) {
                      final comparison = selectedSort == MovieSort.rating
                          ? b.averageRating.compareTo(a.averageRating)
                          : b.year.compareTo(a.year);
                      return comparison != 0
                          ? comparison
                          : a.id.compareTo(b.id);
                    });
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: filteredMovies.isEmpty
                        ? const MovieListEmpty()
                        : MovieGrid(movies: sortedMovies),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
