import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/login_models.dart';

class AuthApiService {
  AuthApiService(this._dio);
  final Dio _dio;

  Future<LoginResult> login(LoginRequest request) => movieLogRequest(() async {
    final response = await _dio.post('/v7/auth/login', data: request.toJson());
    final result = readMovieLogResult(
      response,
      200,
      (value) => LoginResult.fromJson(value as Map<String, dynamic>),
    );
    if (result == null || result.accessToken.isEmpty) {
      throw const MovieLogException('로그인 응답을 확인할 수 없어요.');
    }
    return result;
  });
}
