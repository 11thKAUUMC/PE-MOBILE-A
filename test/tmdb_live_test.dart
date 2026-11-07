import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';

void main() {
  test('개인 토큰으로 실제 TMDB와 Dio·ViewModel 경로를 검증한다', () async {
    dotenv.loadFromString(envString: File('.env').readAsStringSync());
    final dio = createTmdbClient();
    final service = TmdbMovieService(dio);
    final home = MovieHomeViewModel(service);
    final list = MovieListViewModel(service);
    await home.loadPopular();
    expect(home.status, MovieLoadStatus.success);
    expect(home.popularMovies.length, 5);
    await list.loadInitial();
    expect(list.status, MovieLoadStatus.success);
    expect(list.genres, isNotEmpty);
    expect(list.movies.length, 30);
    expect(list.movies.map((m) => m.id).toSet().length, 30);
    await list.selectGenres([28]);
    expect(list.movies.length, 30);
    expect(list.movies.every((m) => m.genreIds.contains(28)), isTrue);
    await list.selectGenres([28, 878]);
    expect(
      list.movies.every(
        (m) => m.genreIds.contains(28) || m.genreIds.contains(878),
      ),
      isTrue,
    );
    await list.selectGenres([]);
    expect(list.movies.length, 30);
    final old = list.movies;
    dio.options.headers['Authorization'] = 'Bearer deliberately-invalid-test';
    await list.refresh();
    expect(list.movies, same(old));
    expect(list.errorVersion, 1);
    dio.options.headers['Authorization'] =
        'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}';
    await list.retry();
    expect(list.status, MovieLoadStatus.success);
    expect(list.message, isNull);
    home.dispose();
    list.dispose();
    dio.close();
  }, skip: !const bool.fromEnvironment('TMDB_LIVE'));
}
