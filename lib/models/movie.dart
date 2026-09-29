class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
}