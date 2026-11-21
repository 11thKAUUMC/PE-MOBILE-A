import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/member_info.dart';

class MemberApiService {
  MemberApiService(this._dio);
  final Dio _dio;

  Future<MemberInfo> fetchMe() => movieLogRequest(() async {
    return _parse(await _dio.get('/v7/members/me'));
  });

  Future<MemberInfo> updateNickname(String nickname) =>
      movieLogRequest(() async {
        return _parse(
          await _dio.patch('/v7/members/me', data: {'nickname': nickname}),
        );
      });

  MemberInfo _parse(Response<dynamic> response) =>
      readMovieLogResult(
        response,
        200,
        (value) => MemberInfo.fromJson(value as Map<String, dynamic>),
      ) ??
      (throw const MovieLogException('내 정보 응답을 확인할 수 없어요.'));
}
