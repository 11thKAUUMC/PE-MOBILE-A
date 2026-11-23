import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor {
  Object? _maskBody(Object? data) {
    if (data is! Map) return data;
    final masked = Map<String, dynamic>.from(data);
    for (final key in ['password', 'accessToken', 'token', 'refreshToken']) {
      if (masked.containsKey(key) && masked[key] != null) {
        masked[key] = '***';
      }
    }
    return masked;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final maskedHeaders = Map<String, dynamic>.from(options.headers);
    if (maskedHeaders.containsKey('Authorization')) {
      maskedHeaders['Authorization'] = 'Bearer ***';
    }
    debugPrint('[HTTP 요청] ${options.method} ${options.uri}');
    debugPrint('[HTTP 요청 Header] $maskedHeaders');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[HTTP 요청 Query] ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('[HTTP 요청 Body] ${_maskBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[HTTP 응답] ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('[HTTP 응답 Body] ${_maskBody(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[HTTP 오류] ${err.requestOptions.uri}');
    debugPrint('[HTTP 오류 내용] ${err.message}');
    handler.next(err);
  }
}
