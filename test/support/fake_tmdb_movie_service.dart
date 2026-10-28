import 'package:dio/dio.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

enum FakeTmdbLoadMode { success, empty, failure }

class FakeTmdbMovieService extends TmdbMovieService {
  FakeTmdbMovieService({this.mode = FakeTmdbLoadMode.success})
    : super(Dio());

  FakeTmdbLoadMode mode;

  static const sampleMovies = [
    TmdbMovieDto(
      id: 1,
      title: '별빛 아래 우리',
      overview: '줄거리',
      posterPath: '/poster1.jpg',
      backdropPath: null,
      releaseDate: '2024-01-01',
      genreIds: [18],
      voteAverage: 8.2,
      popularity: 100,
    ),
    TmdbMovieDto(
      id: 2,
      title: '도시의 밤',
      overview: '줄거리',
      posterPath: null,
      backdropPath: null,
      releaseDate: '2023-05-10',
      genreIds: [28],
      voteAverage: 7.1,
      popularity: 80,
    ),
  ];

  static const sampleGenres = [
    TmdbGenreDto(id: 28, name: '액션'),
    TmdbGenreDto(id: 18, name: '드라마'),
  ];

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _page();
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    String? withGenres,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _page();
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (mode == FakeTmdbLoadMode.failure) {
      throw DioException(requestOptions: RequestOptions(path: '/genre'));
    }
    return sampleGenres;
  }

  TmdbMoviePageDto _page() {
    if (mode == FakeTmdbLoadMode.failure) {
      throw DioException(requestOptions: RequestOptions(path: '/discover'));
    }
    final results = mode == FakeTmdbLoadMode.empty
        ? const <TmdbMovieDto>[]
        : sampleMovies;
    return TmdbMoviePageDto(
      page: 1,
      results: results,
      totalPages: 1,
      totalResults: results.length,
    );
  }
}
