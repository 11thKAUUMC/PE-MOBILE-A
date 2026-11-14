import 'package:dio/dio.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/sign_up_models.dart';

class SignUpService {
  SignUpService(this._dio);
  final Dio _dio;

  Future<bool> checkNickname(String nickname) => _check('nickname', nickname);
  Future<bool> checkEmail(String email) => _check('email', email);

  Future<bool> _check(String field, String value) => movieLogRequest(() async {
    final encoded = Uri.encodeComponent(value.trim());
    final response = await _dio.get<Map<String, dynamic>>(
      '/v6/members/$field/$encoded',
    );
    return CheckResult.fromJson(response.data!).available;
  });

  Future<SignUpResult> signUp(CreateMemberRequest request) =>
      movieLogRequest(() async {
        final response = await _dio.post('/v6/members', data: request.toJson());
        final result = readMovieLogResult(
          response,
          201,
          (json) => SignUpResult.fromJson(json as Map<String, dynamic>),
        );
        if (result == null || result.memberId <= 0) {
          throw const MovieLogException('가입 응답에 회원 번호가 없습니다.');
        }
        return result;
      });
}
