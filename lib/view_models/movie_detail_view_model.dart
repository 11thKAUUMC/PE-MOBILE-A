import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'session_ratings_store.dart';
import 'submit_status.dart';

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._auth,
    this._store,
    this.movie,
  );

  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final SessionRatingsStore _store;
  final TmdbMovieDto movie;
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  bool get canRate => _auth.status == AuthStatus.signedIn;

  Future<void> createRating({required int score, String? comment}) async {
    if (_auth.status != AuthStatus.signedIn) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 로그인해 주세요.';
      notifyListeners();
      return;
    }
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    final version = _auth.sessionVersion;
    notifyListeners();
    try {
      final created = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      if (_disposed || version != _auth.sessionVersion) return;
      _store.upsert(created);
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      if (isSessionAuthError(apiErrorCode(error))) {
        await _auth.expireSession();
        return;
      }
      submitStatus = SubmitStatus.error;
      submitMessage = writeErrorMessage(error);
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
