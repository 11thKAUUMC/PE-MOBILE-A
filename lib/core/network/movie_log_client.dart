import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

Dio createMovieLogClient({AuthInterceptor? auth}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: movieLogOrigin,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: false,
    ),
  );
  if (auth != null) dio.interceptors.add(auth);
  return dio;
}
