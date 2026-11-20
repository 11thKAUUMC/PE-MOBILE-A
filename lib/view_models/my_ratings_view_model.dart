import 'package:flutter/foundation.dart';

import '../data/models/common_response.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_request.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._auth)
    : _version = _auth.sessionVersion {
    _auth.addListener(_sessionChanged);
  }

  final RatingApiService _service;
  final AuthViewModel _auth;
  final _ratings = <int, RatingDto>{};
  final _moviesById = <int, TmdbMovieDto>{};
  int _version;
  bool isWriting = false;
  bool isDeletingSelected = false;

  List<RatingWithMovie> get ratings => [
    for (final rating in _ratings.values.toList().reversed)
      RatingWithMovie(rating: rating, movie: _moviesById[rating.movieId]),
  ];

  RatingDto? forMovie(int movieId) {
    for (final rating in _ratings.values) {
      if (rating.movieId == movieId) return rating;
    }
    return null;
  }

  void _sessionChanged() {
    if (_version == _auth.sessionVersion) return;
    _version = _auth.sessionVersion;
    _ratings.clear();
    _moviesById.clear();
    isWriting = false;
    isDeletingSelected = false;
    notifyListeners();
  }

  Future<void> createRating(TmdbMovieDto movie, RatingInput input) =>
      _write((version) async {
        final rating = await _service.createRating(
          CreateRatingRequest(movieId: movie.id, input: input),
        );
        if (!_auth.isSignedIn(version)) return;
        _moviesById[movie.id] = movie;
        _ratings[rating.ratingId] = rating;
      });

  Future<void> updateRating(int ratingId, RatingInput input) =>
      _write((version) async {
        final rating = await _service.updateRating(ratingId, input);
        if (_auth.isSignedIn(version)) _ratings[rating.ratingId] = rating;
      }, ratingId: ratingId);

  Future<void> deleteRating(int ratingId) =>
      _write((version) => _delete(version, ratingId), ratingId: ratingId);

  Future<void> _delete(int version, int ratingId) async {
    await _service.deleteRating(ratingId);
    if (_auth.isSignedIn(version)) _ratings.remove(ratingId);
  }

  Future<List<int>> deleteSelected(Set<int> ids) async {
    final failures = <int>[];
    await _write((version) async {
      for (final id in ids) {
        if (!_auth.isSignedIn(version)) break;
        try {
          await _delete(version, id);
        } on MovieLogException catch (error) {
          if (error.code == 'RATING404_1' && _auth.isSignedIn(version)) {
            _ratings.remove(id);
          } else {
            failures.add(id);
          }
        }
      }
    }, bulk: true);
    return failures;
  }

  Future<void> _write(
    Future<void> Function(int version) action, {
    int? ratingId,
    bool bulk = false,
  }) async {
    final version = _auth.sessionVersion;
    if (isWriting || !_auth.isSignedIn(version)) {
      throw const MovieLogException('현재 요청이 끝난 뒤 다시 시도해 주세요.');
    }
    isWriting = true;
    isDeletingSelected = bulk;
    notifyListeners();
    try {
      await action(version);
      if (!_auth.isSignedIn(version)) {
        throw const MovieLogException('로그인 상태가 바뀌었어요.');
      }
    } on MovieLogException catch (error) {
      if (!_auth.isSignedIn(version)) {
        throw const MovieLogException('로그인 상태가 바뀌었어요.');
      }
      final message = switch (error.code) {
        'RATING403_1' => '이 평점을 변경할 권한이 없어요.',
        'RATING404_1' => '평점을 찾을 수 없어요.',
        'RATING409_1' => '이미 평점을 남긴 영화예요. 기존 기록을 확인해 주세요.',
        _ => error.message,
      };
      if (error.code == 'RATING404_1') _ratings.remove(ratingId);
      throw MovieLogException(message, status: error.status, code: error.code);
    } finally {
      if (_auth.isSignedIn(version)) {
        isWriting = false;
        isDeletingSelected = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_sessionChanged);
    super.dispose();
  }
}
