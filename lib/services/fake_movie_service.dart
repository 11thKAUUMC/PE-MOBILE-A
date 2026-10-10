import '../data/mock_movies.dart';
import '../models/movie.dart';

enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException();
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // TODO(5주차 유저별 평점 조회 API)
    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(),
    };
  }
}
