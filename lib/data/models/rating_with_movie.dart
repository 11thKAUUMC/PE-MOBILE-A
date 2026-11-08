import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

// lib/data/models/rating_with_movie.dart 를 새로 추가합니다.
class RatingWithMovie {
  const RatingWithMovie({required this.rating, this.movie});

  final RatingDto rating;
  final TmdbMovieDto? movie; // TMDB에서 찾지 못했으면 null입니다.
}
