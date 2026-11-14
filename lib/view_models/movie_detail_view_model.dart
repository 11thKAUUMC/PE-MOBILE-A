import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';

class MovieDetailViewModel {
  MovieDetailViewModel(this._service, this.movieId, this.memberId);
  final RatingApiService _service;
  final int movieId;
  final int memberId;

  Future<void> createRating(RatingInput input) => _service.createRating(
    memberId,
    CreateRatingRequest(movieId: movieId, input: input),
  );
}
