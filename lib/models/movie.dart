class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.ratingCount,
    required this.runtimeMinutes,
    required this.tags,
    required this.synopsis,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final int ratingCount;
  final int runtimeMinutes;
  final List<String> tags;
  final String synopsis;
}
