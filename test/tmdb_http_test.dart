import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/tmdb_logging_interceptor.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';

void main() {
  test(
    '실제 Dio HTTP 경로로 Genre, Popular, Discover와 장르·Empty·Error·재시도를 검증한다',
    () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://127.0.0.1:4015/tmdb/3',
          headers: {'Authorization': 'Bearer simulation-only'},
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      dio.interceptors.add(TmdbLoggingInterceptor());
      final service = TmdbMovieService(dio);
      final home = MovieHomeViewModel(service);
      await home.loadPopular();
      expect(home.popularMovies.length, 5);
      final vm = MovieListViewModel(service);
      await vm.loadInitial();
      expect(vm.genres.length, 2);
      expect(vm.movies.length, 30);
      expect(vm.movies.map((m) => m.id).toSet().length, 30);
      await vm.selectGenres([28, 18]);
      expect(vm.movies.first.genreIds, [28, 18]);
      final previous = vm.movies;
      dio.options.baseUrl = 'http://127.0.0.1:4015/tmdb/unmodeled';
      await vm.refresh();
      expect(vm.movies, same(previous));
      expect(vm.errorVersion, 1);
      dio.options.baseUrl = 'http://127.0.0.1:4015/tmdb/3';
      await vm.retry();
      expect(vm.status, MovieLoadStatus.success);
      await vm.selectGenres([999999]);
      expect(vm.status, MovieLoadStatus.empty);
      await vm.selectGenres([]);
      expect(vm.movies.length, 30);
      home.dispose();
      vm.dispose();
      dio.close();
    },
    skip: !const bool.fromEnvironment('TMDB_SIMULATION'),
  );
}
