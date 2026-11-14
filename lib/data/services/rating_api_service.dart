import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  String _path(int memberId) => '/v6/members/$memberId/ratings';

  Future<List<RatingDto>> fetchMyRatings(int memberId) =>
      movieLogRequest(() async {
        final response = await _dio.get<List<dynamic>>(_path(memberId));
        return response.data!
            .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
            .toList();
      });

  Future<void> createRating(int memberId, CreateRatingRequest request) =>
      movieLogRequest(() async {
        final response = await _dio.post(
          _path(memberId),
          data: request.toJson(),
        );
        readMovieLogResult(response, 201, (value) => value);
      });

  Future<void> updateRating(int memberId, int ratingId, RatingInput input) =>
      movieLogRequest(() async {
        final response = await _dio.patch(
          '${_path(memberId)}/$ratingId',
          data: input.toJson(),
        );
        readMovieLogResult(response, 200, (value) => value);
      });

  Future<void> deleteRating(int memberId, int ratingId) => movieLogRequest(
    () async {
      final response = await _dio.delete<void>('${_path(memberId)}/$ratingId');
      if (response.statusCode != 204) {
        throw const MovieLogException('삭제 응답을 확인할 수 없습니다.');
      }
    },
  );
}

String writeMyRatingsErrorMessage(DioException error) =>
    MovieLogException.fromDio(error).message;
