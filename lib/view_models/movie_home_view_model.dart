import 'package:flutter/foundation.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import 'movie_list_view_model.dart';

class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this.service);
  final TmdbMovieService service;
  List<TmdbMovieDto> popularMovies = const [];
  MovieLoadStatus status = MovieLoadStatus.idle;
  bool _disposed = false;
  int _version = 0;
  Future<void> loadPopular() async {
    final version = ++_version;
    status = MovieLoadStatus.loading;
    notifyListeners();
    try {
      final page = await service.fetchPopular();
      if (_disposed || version != _version) return;
      popularMovies = List.unmodifiable(page.results.take(5));
      status = popularMovies.isEmpty
          ? MovieLoadStatus.empty
          : MovieLoadStatus.success;
    } catch (_) {
      if (_disposed || version != _version) return;
      status = MovieLoadStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    super.dispose();
  }
}
