import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final TokenStorage _storage;

  bool _isProtected(RequestOptions options) {
    final path = options.uri.path;
    return options.uri.host == 'workbook.devnoco.com' &&
        (path == '/v7/members/me' ||
            path == '/v7/ratings' ||
            path.startsWith('/v7/ratings/'));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }
    // 이전 요청의 토큰을 재사용하지 않습니다.
    options.headers.remove('Authorization');
    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('인증 저장소를 읽지 못했습니다.'),
        ),
      );
    }
  }
}
