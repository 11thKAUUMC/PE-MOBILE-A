import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/common_response.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(this._service, this._movieService, this.memberId);
  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;
  final Map<int, TmdbMovieDto?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning;
  bool isWriting = false;
  bool isDeletingSelected = false;

  Future<void> updateRating(int ratingId, RatingInput input) =>
      _write(() => _service.updateRating(memberId, ratingId, input));

  Future<void> deleteRating(int ratingId) => _write(
    () => _service.deleteRating(memberId, ratingId),
    deleted: ratingId,
  );

  Future<void> _write(Future<void> Function() request, {int? deleted}) async {
    if (_disposed || isWriting) return;
    isWriting = true;
    notifyListeners();
    try {
      await request();
      if (_disposed) return;
      if (deleted != null) {
        ratings = ratings
            .where((entry) => entry.rating.ratingId != deleted)
            .toList();
      }
      await _refreshAfterWrite();
    } on MovieLogException catch (error) {
      if (error.status == 403 || error.status == 404) await _load();
      rethrow;
    } finally {
      isWriting = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<List<int>> deleteSelected(Set<int> ids) async {
    if (_disposed || isWriting || ids.isEmpty) return [];
    isWriting = true;
    isDeletingSelected = true;
    notifyListeners();
    final succeeded = <int>{};
    final failed = <int>[];
    try {
      for (final id in ids.toList()) {
        if (_disposed) break;
        try {
          await _service.deleteRating(memberId, id);
          succeeded.add(id);
        } catch (_) {
          failed.add(id);
        }
      }
      if (!_disposed && succeeded.isNotEmpty) {
        ratings = ratings
            .where((entry) => !succeeded.contains(entry.rating.ratingId))
            .toList();
        await _refreshAfterWrite();
      }
      return failed;
    } finally {
      isWriting = false;
      isDeletingSelected = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _refreshAfterWrite() async {
    refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
    await _load();
  }

  Future<void> load() async {
    if (!isWriting) await _load();
  }

  Future<void> _load() async {
    if (_disposed) return;
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();
    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion) return;
      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      // 같은 movieId는 캐시를 사용하고, 영화 조회 실패가 평점 목록을 지우지 않습니다.
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] = await _movieService.findMovieById(
              rating.movieId,
            );
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않습니다. 다음 로딩에서 재시도합니다.
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }
      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      refreshWarning = null;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on MovieLogException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = error.message;
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    } catch (_) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = '평점 응답을 읽지 못했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
