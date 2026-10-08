import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../models/movie_sort.dart';
import '../services/fake_movie_service.dart';
import '../services/movie_preference.dart';
import '../widgets/common_app_bar.dart';
import 'genre_chips.dart';
import 'movie_grid.dart';
import 'movie_list_empty.dart';
import 'movie_list_error.dart';
import 'movie_list_loading.dart';
import 'movie_sort_menu.dart';

/// 화면 상태 확인용: success / empty / failure / timeout
const defaultMovieLoadMode = MovieLoadMode.success;

class MovieListInitialData {
  const MovieListInitialData({
    required this.movies,
    required this.selectedGenre,
    required this.sort,
  });

  final List<Movie> movies;
  final String selectedGenre;
  final MovieSort sort;
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({
    super.key,
    this.loadMode = defaultMovieLoadMode,
    this.movieService = const FakeMovieService(),
    this.preference,
    this.timeout = const Duration(seconds: 3),
  });

  final MovieLoadMode loadMode;
  final FakeMovieService movieService;
  final MoviePreference? preference;
  final Duration timeout;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static final _genres = [MoviePreference.allGenre, ...movieGenres];

  late final MoviePreference _preference =
      widget.preference ?? MoviePreference();
  late Future<MovieListInitialData> _initialDataFuture;

  String? _selectedGenre;
  MovieSort? _sort;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _loadInitialData(widget.loadMode);
  }

  Future<MovieListInitialData> _loadInitialData(MovieLoadMode mode) async {
    try {
      final results = await Future.wait<Object>([
        widget.movieService.fetchMovies(mode: mode).timeout(widget.timeout),
        _preference.readGenre(),
        _preference.readSort(),
      ]);

      return MovieListInitialData(
        movies: results[0] as List<Movie>,
        selectedGenre: results[1] as String,
        sort: results[2] as MovieSort,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('영화 목록 로드 실패: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      debugPrint('영화 목록 로드 시도 종료');
    }
  }

  void _retry() {
    setState(() {
      _initialDataFuture = _loadInitialData(MovieLoadMode.success);
    });
  }

  Future<void> _refresh() async {
    final future = _loadInitialData(MovieLoadMode.success);
    setState(() {
      _initialDataFuture = future;
    });

    try {
      await future;
    } on Exception {
      return;
    }
  }

  Future<void> _selectGenre(String genre) async {
    setState(() => _selectedGenre = genre);
    await _preference.saveGenre(genre);
  }

  Future<void> _selectSort(MovieSort sort) async {
    setState(() => _sort = sort);
    await _preference.saveSort(sort);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '영화'),
      body: FutureBuilder<MovieListInitialData>(
        future: _initialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const MovieListLoading();
          }

          if (snapshot.hasError) {
            return MovieListError(
              onRetry: _retry,
              message: snapshot.error is TimeoutException
                  ? MovieListError.timeoutMessage
                  : MovieListError.defaultMessage,
            );
          }

          final data = snapshot.data;
          if (data == null || data.movies.isEmpty) {
            return const MovieListEmpty();
          }

          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildContent(MovieListInitialData data) {
    final savedGenre = _selectedGenre ?? data.selectedGenre;
    final genre = _genres.contains(savedGenre)
        ? savedGenre
        : MoviePreference.allGenre;
    final sort = _sort ?? data.sort;

    final filteredMovies = genre == MoviePreference.allGenre
        ? data.movies
        : data.movies.where((movie) => movie.genre == genre).toList();
    final visibleMovies = sort.apply(filteredMovies);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GenreChips(
                genres: _genres,
                selected: genre,
                onSelected: _selectGenre,
              ),
            ),
            MovieSortMenu(selected: sort, onSelected: _selectSort),
            const SizedBox(width: 8),
          ],
        ),
        Expanded(
          child: visibleMovies.isEmpty
              ? const MovieListEmpty()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: MovieGrid(movies: visibleMovies),
                ),
        ),
      ],
    );
  }
}
