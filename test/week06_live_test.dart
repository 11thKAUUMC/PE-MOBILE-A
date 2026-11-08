import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';

void main() {
  test('v5 GET와 TMDB 상세를 실제 Dio 경로로 검증한다', () async {
    dotenv.loadFromString(envString: File('.env').readAsStringSync());
    final backend = createMovieLogClient();
    final tmdb = createTmdbClient();
    final checks = MemberCheckService(backend);
    final ratings = RatingApiService(backend);
    expect(await checks.checkNickname('영화광'), false);
    expect(await checks.checkEmail('movie@umc.com'), false);
    expect(await checks.checkNickname('week06_readonly_20261106'), true);
    expect(
      await checks.checkEmail('week06_readonly_20261106@example.com'),
      true,
    );
    final rows = await ratings.fetchMyRatings(1);
    expect(rows, isNotEmpty);
    expect(rows.any((r) => r.comment == null), true);
    for (final item in [('abc', 400), ('999999999', 404)]) {
      try {
        await backend.get('/v5/members/${item.$1}/ratings');
        fail('expected ${item.$2}');
      } on DioException catch (e) {
        expect(e.response?.statusCode, item.$2);
      }
    }
    final vm = MyRatingsViewModel(ratings, TmdbMovieService(tmdb), 1);
    await vm.load();
    expect(vm.status, MyRatingsLoadStatus.success);
    expect(vm.ratings.length, rows.length);
    expect(vm.ratings.every((entry) => entry.movie != null), true);
    // ignore: avoid_print
    print(
      'v5 nickname/email available·duplicated, ratings 400·404, memberId=1 ${rows.length} ratings + TMDB titles verified; GET only.',
    );
    vm.dispose();
    backend.close();
    tmdb.close();
  }, skip: !const bool.fromEnvironment('WEEK06_LIVE'));
}
