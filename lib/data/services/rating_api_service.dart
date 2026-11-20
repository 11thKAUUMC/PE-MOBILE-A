import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;
  static const _path = '/v7/ratings';

  Future<List<RatingDto>> fetchPublicRatings(int memberId) =>
      movieLogRequest(() async {
        final response = await _publicDio.get<List<dynamic>>(
          '/v7/members/$memberId/ratings',
        );
        return response.data!
            .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
            .toList();
      });

  Future<RatingDto> createRating(CreateRatingRequest request) =>
      _write(() => _authDio.post(_path, data: request.toJson()), 201);

  Future<RatingDto> updateRating(int ratingId, RatingInput input) => _write(
    () => _authDio.patch(
      '$_path/$ratingId',
      data: {'score': input.score, 'comment': input.comment},
    ),
    200,
  );

  Future<RatingDto> _write(
    Future<Response<dynamic>> Function() request,
    int status,
  ) => movieLogRequest(() async {
    return readMovieLogResult(
          await request(),
          status,
          (value) => RatingDto.fromJson(value as Map<String, dynamic>),
        ) ??
        (throw const MovieLogException('평점 응답을 확인할 수 없어요.'));
  });

  Future<void> deleteRating(int ratingId) => movieLogRequest(() async {
    final response = await _authDio.delete('$_path/$ratingId');
    if (readMovieLogResult(response, 200, (value) => value) != null) {
      throw const MovieLogException('평점 삭제 응답을 확인할 수 없어요.');
    }
  });
}
