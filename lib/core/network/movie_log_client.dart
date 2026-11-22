import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'tmdb_logging_interceptor.dart';

BaseOptions _movieLogOptions() {
  return BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );
}

void _addDebugLogging(Dio dio) {
  if (kDebugMode) {
    dio.interceptors.add(TmdbLoggingInterceptor());
  }
}

/// 공개 요청용: 로그인, 중복 체크, 유저별 평점 조회. Interceptor 없음.
Dio createMovieLogClient() {
  final dio = Dio(_movieLogOptions());
  _addDebugLogging(dio);
  return dio;
}

/// 보호 요청용: 내 정보, 평점 등록/수정/삭제. AuthInterceptor 등록.
Dio createAuthMovieLogClient(TokenStorage storage) {
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(AuthInterceptor(storage));
  _addDebugLogging(dio);
  return dio;
}
