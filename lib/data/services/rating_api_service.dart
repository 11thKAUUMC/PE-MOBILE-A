import 'package:dio/dio.dart';

import '../../core/network/api_error.dart';
import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;

  /// 공개 조회: 토큰 없음. v7 계약에 memberId path 유지.
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post(
      '/v7/ratings',
      data: request.toJson(),
    );
    return parseRatingResult(response.data);
  }

  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return parseRatingResult(response.data);
  }

  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답');
    }
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final code = apiErrorCode(error);
  if (code == 'MEMBER404_1') return '존재하지 않는 회원입니다.';
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

String writeErrorMessage(DioException error) {
  final code = apiErrorCode(error);
  switch (code) {
    case 'RATING403_1':
      return '본인이 작성한 평점만 변경할 수 있어요.';
    case 'RATING409_1':
      return '이미 이 영화에 평점을 남겼어요. 기존 기록을 확인해 주세요.';
    case 'RATING404_1':
      return '평점을 찾을 수 없어요.';
    case 'COMMON400':
      return apiErrorMessage(error) ?? '입력값을 확인해 주세요.';
  }
  return apiErrorMessage(error) ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

bool shouldRefreshAfterRatingError(DioException error) {
  final code = apiErrorCode(error);
  return code == 'RATING403_1' ||
      code == 'RATING404_1' ||
      code == 'COMMON403' ||
      code == 'COMMON404';
}
