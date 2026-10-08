import '../data/mock_movies.dart';
import '../models/movie.dart';

enum MovieLoadMode { success, empty, failure, timeout }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;

  @override
  String toString() => 'MovieLoadException: $message';
}

// TODO(5주차 유저별 평점 조회 API): Swagger의 실제 API Service로 교체합니다.
class FakeMovieService {
  const FakeMovieService({
    this.delay = const Duration(seconds: 1),
    this.slowDelay = const Duration(seconds: 10),
  });

  final Duration delay;

  /// [MovieLoadMode.timeout]에서 사용하는 지연 시간으로, 화면의 Timeout보다 길어야 합니다.
  final Duration slowDelay;

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    await Future<void>.delayed(
      mode == MovieLoadMode.timeout ? slowDelay : delay,
    );

    return switch (mode) {
      MovieLoadMode.success || MovieLoadMode.timeout => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}
