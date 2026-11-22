import 'package:flutter/foundation.dart';

import '../data/models/rating_dto.dart';

/// v7에는 토큰 기반 내 평점 전체 GET이 없으므로,
/// 현재 세션에서 등록·수정한 Rating만 메모리에 보관합니다.
class SessionRatingsStore extends ChangeNotifier {
  final List<RatingDto> _ratings = [];
  bool _disposed = false;

  List<RatingDto> get ratings => List.unmodifiable(_ratings);

  void upsert(RatingDto rating) {
    if (_disposed) return;
    final index = _ratings.indexWhere((r) => r.ratingId == rating.ratingId);
    if (index >= 0) {
      _ratings[index] = rating;
    } else {
      _ratings.insert(0, rating);
    }
    notifyListeners();
  }

  void remove(int ratingId) {
    if (_disposed) return;
    _ratings.removeWhere((r) => r.ratingId == ratingId);
    notifyListeners();
  }

  void clear() {
    if (_disposed) return;
    _ratings.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
