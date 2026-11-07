import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';

enum MovieLoadStatus { idle, loading, empty, error, success }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this.service);
  final TmdbMovieService service;
  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  List<int> selectedGenreIds = const [];
  MovieLoadStatus status = MovieLoadStatus.idle;
  String? message;
  bool refreshing = false;
  int errorVersion = 0;
  int _version = 0;
  bool _disposed = false;
  bool get busy => status == MovieLoadStatus.loading || refreshing;

  Future<void> loadInitial() => _load(loadGenres: true);
  Future<void> selectGenres(List<int> ids) async {
    if (busy) return;
    selectedGenreIds = List.unmodifiable(ids);
    movies = const [];
    await _load(loadGenres: genres.isEmpty);
  }

  Future<void> retry() =>
      _load(loadGenres: genres.isEmpty, preserve: movies.isNotEmpty);
  Future<void> refresh() async {
    if (busy) return;
    await _load(preserve: true);
  }

  Future<void> _load({bool loadGenres = false, bool preserve = false}) async {
    final version = ++_version;
    final ids = List<int>.of(selectedGenreIds);
    refreshing = preserve && movies.isNotEmpty;
    if (!refreshing) status = MovieLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      final loadedGenres = loadGenres ? await service.fetchGenres() : genres;
      final byId = <int, TmdbMovieDto>{};
      var pageNumber = 1;
      while (byId.length < 30) {
        final page = await service.discoverMovies(
          page: pageNumber,
          genreIds: ids,
        );
        if (_disposed || version != _version) return;
        for (final movie in page.results) {
          byId.putIfAbsent(movie.id, () => movie);
          if (byId.length == 30) break;
        }
        if (page.results.isEmpty || pageNumber >= page.totalPages) break;
        pageNumber++;
      }
      if (_disposed || version != _version) return;
      genres = List.unmodifiable(loadedGenres);
      movies = List.unmodifiable(byId.values);
      status = movies.isEmpty ? MovieLoadStatus.empty : MovieLoadStatus.success;
    } catch (_) {
      if (_disposed || version != _version) return;
      message = '영화를 불러오지 못했습니다. 연결과 TMDB 토큰을 확인해 주세요.';
      status = movies.isEmpty ? MovieLoadStatus.error : MovieLoadStatus.success;
      errorVersion++;
    }
    if (_disposed || version != _version) return;
    refreshing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    super.dispose();
  }
}
