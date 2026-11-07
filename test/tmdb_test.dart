import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';

class FixtureService extends TmdbMovieService {
  FixtureService() : super(Dio());
  final calls = <(int, List<int>?)>[];
  bool fail = false;
  bool empty = false;
  Completer<void>? gate;
  @override
  Future<List<TmdbGenreDto>> fetchGenres() async => const [
    TmdbGenreDto(id: 28, name: '액션'),
    TmdbGenreDto(id: 18, name: '드라마'),
  ];
  @override
  Future<TmdbMoviePageDto> fetchPopular() async => TmdbMoviePageDto(
    page: 1,
    totalPages: 1,
    results: List.generate(3, (i) => TmdbMovieDto(id: i + 100, title: '영화 $i')),
  );
  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    List<int>? genreIds,
  }) async {
    calls.add((page, genreIds));
    if (gate != null) await gate!.future;
    if (fail) throw StateError('fixture failure');
    return TmdbMoviePageDto(
      page: page,
      totalPages: 3,
      results: empty
          ? []
          : List.generate(
              20,
              (i) => TmdbMovieDto(id: (page - 1) * 19 + i, title: '영화 $i'),
            ),
    );
  }
}

void main() {
  test('DTO null, snake_case, 정수 평점과 빈 날짜를 변환한다', () {
    final dto = TmdbMovieDto.fromJson({
      'id': 42,
      'title': '테스트',
      'vote_average': 8,
      'genre_ids': [28],
    });
    expect(dto.posterPath, isNull);
    expect(dto.voteAverage, 8.0);
    expect(dto.toMovie(const []).year, 0);
    expect(dto.toMovie(const []).id, 42);
  });
  test('인기 응답이 5개 미만이어도 표시한다', () async {
    final vm = MovieHomeViewModel(FixtureService());
    await vm.loadPopular();
    expect(vm.popularMovies.length, 3);
    expect(vm.status, MovieLoadStatus.success);
    vm.dispose();
  });
  test('페이지 중복 제거 후 30개에서 멈추고 장르 OR 조건을 유지한다', () async {
    final service = FixtureService();
    final vm = MovieListViewModel(service);
    await vm.loadInitial();
    expect(vm.movies.length, 30);
    expect(vm.movies.map((m) => m.id).toSet().length, 30);
    expect(service.calls.map((c) => c.$1), [1, 2]);
    await vm.selectGenres([28, 18]);
    expect(service.calls.last.$2, [28, 18]);
    service.fail = true;
    final previous = vm.movies;
    await vm.refresh();
    expect(vm.movies, same(previous));
    expect(vm.errorVersion, 1);
    service.fail = false;
    await vm.retry();
    expect(service.calls[service.calls.length - 2].$1, 1);
    expect(service.calls.last.$2, [28, 18]);
    await vm.selectGenres([]);
    expect(service.calls.last.$2, isEmpty);
    vm.dispose();
  });
  test('빈 응답, 실패, 재시도와 로딩 중 장르 입력을 처리한다', () async {
    final service = FixtureService()..empty = true;
    final vm = MovieListViewModel(service);
    await vm.loadInitial();
    expect(vm.status, MovieLoadStatus.empty);
    service.fail = true;
    await vm.retry();
    expect(vm.status, MovieLoadStatus.error);
    service.fail = false;
    service.empty = false;
    service.gate = Completer<void>();
    final loading = vm.retry();
    await vm.selectGenres([28]);
    expect(vm.selectedGenreIds, isEmpty);
    service.gate!.complete();
    await loading;
    expect(vm.status, MovieLoadStatus.success);
    vm.dispose();
  });
  test('dispose 이후 응답이 도착해도 알림을 보내지 않는다', () async {
    final service = FixtureService()..gate = Completer<void>();
    final vm = MovieListViewModel(service);
    final loading = vm.loadInitial();
    vm.dispose();
    service.gate!.complete();
    await loading;
  });
}
