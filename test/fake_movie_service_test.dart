import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/services/fake_movie_service.dart';

void main() {
  const service = FakeMovieService(
    delay: Duration(milliseconds: 10),
    slowDelay: Duration(milliseconds: 200),
  );

  test('success 모드는 Mock 영화 목록을 반환한다', () async {
    expect(await service.fetchMovies(), movies);
  });

  test('empty 모드는 빈 목록을 반환한다', () async {
    expect(await service.fetchMovies(mode: MovieLoadMode.empty), isEmpty);
  });

  test('failure 모드는 MovieLoadException으로 완료된다', () async {
    await expectLater(
      service.fetchMovies(mode: MovieLoadMode.failure),
      throwsA(isA<MovieLoadException>()),
    );
  });

  test('timeout 모드는 Future.timeout보다 늦게 완료된다', () async {
    await expectLater(
      service
          .fetchMovies(mode: MovieLoadMode.timeout)
          .timeout(const Duration(milliseconds: 50)),
      throwsA(isA<Exception>()),
    );
  });
}
