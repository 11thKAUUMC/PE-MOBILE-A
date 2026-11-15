import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'tmdb_logging_interceptor.dart';

Dio createMovieLogClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(TmdbLoggingInterceptor());
  }

  return dio;
}
