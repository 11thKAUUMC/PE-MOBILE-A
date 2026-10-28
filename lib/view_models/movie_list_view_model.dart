import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);

  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  List<int> selectedGenreIds = const [];
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;
  bool showRetryDialog = false;
  bool isRefreshing = false;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading =>
      status == MovieListLoadStatus.loading ||
      status == MovieListLoadStatus.idle;

  bool get canChangeGenre => !isLoading && !isRefreshing;

  String? get _withGenresQuery {
    if (selectedGenreIds.isEmpty) return null;
    return selectedGenreIds.join('|');
  }

  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({
    String? withGenres,
  }) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        withGenres: withGenres,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == 30) break;
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }

    return byId.values.take(30).toList();
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    showRetryDialog = false;
    notifyListeners();

    try {
      genres = await _service.fetchGenres();
      final discovered = await fetchUpToThirtyMovies(
        withGenres: _withGenresQuery,
      );

      if (_disposed || version != _requestVersion) return;
      movies = discovered;
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
      message = null;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
      showRetryDialog = movies.isNotEmpty;
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  Future<void> selectGenres(List<int> genreIds) async {
    selectedGenreIds = List<int>.unmodifiable(genreIds);
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    showRetryDialog = false;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(withGenres: _withGenresQuery);
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
      message = null;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
      showRetryDialog = movies.isNotEmpty;
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  /// Required 단일 장르 Chip용. null이면 전체.
  Future<void> selectGenre(int? genreId) {
    return selectGenres(genreId == null ? const [] : [genreId]);
  }

  Future<void> refresh() async {
    if (isLoading || isRefreshing) return;

    final version = ++_requestVersion;
    isRefreshing = true;
    showRetryDialog = false;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(withGenres: _withGenresQuery);
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
      message = null;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
      if (movies.isNotEmpty) {
        showRetryDialog = true;
      } else {
        status = MovieListLoadStatus.error;
      }
    } finally {
      if (!_disposed && version == _requestVersion) {
        isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> retryLastRequest() async {
    showRetryDialog = false;
    if (movies.isEmpty && genres.isEmpty) {
      await loadInitial();
      return;
    }
    await selectGenres(selectedGenreIds);
  }

  void dismissRetryDialog() {
    showRetryDialog = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
