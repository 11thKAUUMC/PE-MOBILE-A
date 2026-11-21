import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

void main() {
  test('공개 v7 GET와 TMDB 상세를 실제 Dio 경로로 검증한다', () async {
    dotenv.loadFromString(envString: File('.env').readAsStringSync());
    final backend = createMovieLogClient();
    final tmdb = createTmdbClient();
    final checks = MemberCheckService(backend);
    final ratings = RatingApiService(backend, backend);
    expect(await checks.checkNickname('영화광'), false);
    expect(await checks.checkEmail('movie@umc.com'), false);
    expect(await checks.checkNickname('week06_readonly_20261106'), true);
    expect(
      await checks.checkEmail('week06_readonly_20261106@example.com'),
      true,
    );
    final rows = await ratings.fetchPublicRatings(1);
    expect(rows, isNotEmpty);
    expect(rows.any((r) => r.comment == null), true);
    for (final item in [('abc', 400), ('999999999', 404)]) {
      try {
        await backend.get('/v7/members/${item.$1}/ratings');
        fail('expected ${item.$2}');
      } on DioException catch (e) {
        expect(e.response?.statusCode, item.$2);
      }
    }
    final movies = TmdbMovieService(tmdb);
    for (final row in rows) {
      expect(await movies.findMovieById(row.movieId), isNotNull);
    }
    // ignore: avoid_print
    print(
      'nickname/email available·duplicated, ratings 400·404, memberId=1 ${rows.length} ratings + TMDB titles verified; GET only.',
    );
    backend.close();
    tmdb.close();
  }, skip: !const bool.fromEnvironment('WEEK06_LIVE'));
}
