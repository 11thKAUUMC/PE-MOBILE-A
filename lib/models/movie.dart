class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    this.rating = 0.0,
    this.ratingCount = 1245,
    this.runtime = '124분',
    this.tags = const ['로맨스', '드라마', '감동적인'],
    this.description,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final String posterAsset;
  final double rating;
  final int ratingCount;
  final String runtime;
  final List<String> tags;
  final String? description;
}
