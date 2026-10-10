import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/services/fake_movie_service.dart';

void main() {
  const service = FakeMovieService();

  group('FakeMovieService', () {
    test('성공 모드는 기존 Mock 영화 목록을 반환한다', () async {
      final result = await service.fetchMovies(mode: MovieLoadMode.success);

      expect(result, isNotEmpty);
      expect(result, orderedEquals(movies));
    });

    test('빈 목록 모드는 오류 없이 빈 영화 목록을 반환한다', () async {
      final result = await service.fetchMovies(mode: MovieLoadMode.empty);

      expect(result, isEmpty);
    });

    test('실패 모드는 MovieLoadException으로 완료된다', () async {
      await expectLater(
        service.fetchMovies(mode: MovieLoadMode.failure),
        throwsA(isA<MovieLoadException>()),
      );
    });
  });
}
