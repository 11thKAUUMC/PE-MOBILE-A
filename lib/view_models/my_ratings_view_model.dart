import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';
import 'session_ratings_store.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._store,
    this._auth,
  ) {
    _store.addListener(_onStoreChanged);
  }

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final SessionRatingsStore _store;
  final AuthViewModel _auth;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning;

  bool isEditMode = false;
  final Set<int> selectedRatingIds = {};
  bool isDeletingSelected = false;

  void _onStoreChanged() {
    if (!_disposed) {
      load();
    }
  }

  Future<void> load() async {
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      // v7 토큰 기반 내 평점 전체 GET이 없으므로 세션 로컬 목록만 표시합니다.
      final rawRatings = List<RatingDto>.from(_store.ratings);
      if (_disposed || version != _requestVersion) return;
      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않습니다.
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }
      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } catch (_) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = '평점 목록을 불러오지 못했습니다.';
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  void enterEditMode() {
    isEditMode = true;
    selectedRatingIds.clear();
    notifyListeners();
  }

  void exitEditMode() {
    isEditMode = false;
    selectedRatingIds.clear();
    notifyListeners();
  }

  void toggleSelection(int ratingId) {
    if (selectedRatingIds.contains(ratingId)) {
      selectedRatingIds.remove(ratingId);
    } else {
      selectedRatingIds.add(ratingId);
    }
    notifyListeners();
  }

  Future<void> _refreshAfterWrite() async {
    await load();
    refreshWarning = null;
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_disposed || version != _auth.sessionVersion) return;
      _store.upsert(updated);
    } on DioException catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      if (isSessionAuthError(apiErrorCode(error))) {
        await _auth.expireSession();
        return;
      }
      message = writeErrorMessage(error);
      notifyListeners();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (_disposed || version != _auth.sessionVersion) return;
      _store.remove(ratingId);
    } on DioException catch (error) {
      if (_disposed || version != _auth.sessionVersion) return;
      if (isSessionAuthError(apiErrorCode(error))) {
        await _auth.expireSession();
        return;
      }
      message = writeErrorMessage(error);
      notifyListeners();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return;
    isDeletingSelected = true;
    notifyListeners();
    var failed = 0;
    final version = _auth.sessionVersion;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        if (version != _auth.sessionVersion) return;
        try {
          await _service.deleteRating(ratingId);
          if (version != _auth.sessionVersion) return;
          _store.remove(ratingId);
          selectedRatingIds.remove(ratingId);
        } on DioException catch (error) {
          if (isSessionAuthError(apiErrorCode(error))) {
            await _auth.expireSession();
            return;
          }
          failed++;
        }
      }
    } finally {
      isDeletingSelected = false;
      notifyListeners();
    }
    await _refreshAfterWrite();
    if (failed > 0) {
      message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      notifyListeners();
    } else if (selectedRatingIds.isEmpty) {
      isEditMode = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }
}
