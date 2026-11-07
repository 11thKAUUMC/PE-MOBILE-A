import '../../models/movie.dart';

class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview = '',
    this.releaseDate = '',
    this.voteAverage = 0,
    this.genreIds = const [],
  });
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) => TmdbMovieDto(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '',
    posterPath: json['poster_path'] as String?,
    overview: json['overview'] as String? ?? '',
    releaseDate: json['release_date'] as String? ?? '',
    voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
    genreIds: (json['genre_ids'] as List? ?? [])
        .map((id) => (id as num).toInt())
        .toList(),
  );

  Movie toMovie(List<TmdbGenreDto> genres) {
    final names = genres
        .where((g) => genreIds.contains(g.id))
        .map((g) => g.name)
        .toList();
    return Movie(
      id: id,
      title: title,
      genre: names.join(' · '),
      year: int.tryParse(releaseDate.split('-').first) ?? 0,
      posterAsset: '',
      posterPath: posterPath,
      isTmdb: true,
      duration: 0,
      averageRating: voteAverage / 2,
      synopsis: overview,
      tags: names,
    );
  }
}

class TmdbGenreDto {
  const TmdbGenreDto({required this.id, required this.name});
  final int id;
  final String name;
  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) => TmdbGenreDto(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
  );
}

class TmdbMoviePageDto {
  const TmdbMoviePageDto({
    required this.page,
    required this.totalPages,
    required this.results,
  });
  final int page;
  final int totalPages;
  final List<TmdbMovieDto> results;
  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) =>
      TmdbMoviePageDto(
        page: (json['page'] as num? ?? 1).toInt(),
        totalPages: (json['total_pages'] as num? ?? 0).toInt(),
        results: (json['results'] as List? ?? [])
            .map((e) => TmdbMovieDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
