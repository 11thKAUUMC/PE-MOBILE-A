import 'package:dio/dio.dart';

import '../../data/models/common_response.dart';

const movieLogOrigin = 'https://workbook.devnoco.com';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.session, required this.onExpired});

  final ({String? token, int version}) Function() session;
  final Future<void> Function(int version) onExpired;
  static const _versionKey = 'movieLogSessionVersion';
  static final _ratingPath = RegExp(r'^/v7/ratings/[1-9][0-9]*$');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.removeWhere(
      (key, _) => key.toLowerCase() == 'authorization',
    );
    options.extra.remove(_versionKey);
    final uri = options.uri;
    final method = options.method;
    final protectedPath = switch (uri.path) {
      '/v7/members/me' => method == 'GET' || method == 'PATCH',
      '/v7/ratings' => method == 'POST',
      _ =>
        _ratingPath.hasMatch(uri.path) &&
            (method == 'PATCH' || method == 'DELETE'),
    };
    if (uri.origin == movieLogOrigin && protectedPath) {
      options.followRedirects = false;
      final current = session();
      options.extra[_versionKey] = current.version;
      final token = current.token;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final version = err.requestOptions.extra[_versionKey];
    final failure = MovieLogException.fromDio(err);
    if (version is int &&
        failure.status == 401 &&
        const {'AUTH401_2', 'AUTH401_3', 'AUTH401_4'}.contains(failure.code)) {
      await onExpired(version);
    }
    handler.next(err);
  }
}
