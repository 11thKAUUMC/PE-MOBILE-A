import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';

class RatingWithMovie {
  const RatingWithMovie({required this.rating, this.movie});

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 찾지 못했으면 null입니다.
}
