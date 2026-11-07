import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '[TMDB 요청] ${options.method} ${options.uri} Authorization: Bearer ***',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[TMDB 응답 Body] ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Exception 전체를 출력하면 RequestOptions의 인증 값이 노출될 수 있다.
    debugPrint(
      '[TMDB 오류] ${err.requestOptions.uri} status=${err.response?.statusCode} type=${err.type.name}',
    );
    handler.next(err);
  }
}
