class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.genreIds,
    required this.voteAverage,
    required this.popularity,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final double popularity;

  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds: _parseGenreIds(json),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      popularity: (json['popularity'] as num? ?? 0).toDouble(),
    );
  }

  String? get releaseYear {
    final date = releaseDate;
    if (date == null || date.length < 4) return null;
    return date.substring(0, 4);
  }

  static List<int> _parseGenreIds(Map<String, dynamic> json) {
    final genreIds = json['genre_ids'] as List<dynamic>?;
    if (genreIds != null) {
      return genreIds.map((value) => (value as num).toInt()).toList();
    }
    final genres = json['genres'] as List<dynamic>?;
    if (genres == null) return const [];
    return genres
        .map((item) => ((item as Map<String, dynamic>)['id'] as num).toInt())
        .toList();
  }
}
