import 'package:dio/dio.dart';

class CommonResponse<T> {
  CommonResponse.fromJson(Map<String, dynamic> json, T Function(Object?) parse)
    : isSuccess = json['isSuccess'] as bool,
      code = json['code'] as String,
      message = json['message'] as String,
      result = json['result'] == null ? null : parse(json['result']);

  final bool isSuccess;
  final String code;
  final String message;
  final T? result;
}

class MovieLogException implements Exception {
  const MovieLogException(this.message, {this.status, this.code});

  final String message;
  final int? status;
  final String? code;

  factory MovieLogException.fromDio(DioException error) {
    final body = error.response?.data;
    final status = error.response?.statusCode;
    final message = body is Map ? body['message'] : null;
    final code = body is Map ? body['code'] : null;
    return MovieLogException(
      message is String && message.isNotEmpty
          ? message
          : switch (status) {
              400 => '입력값을 확인해 주세요.',
              403 => '이 평점을 변경할 권한이 없습니다.',
              404 => '요청한 정보를 찾을 수 없습니다.',
              409 => '이미 등록된 정보입니다.',
              _ => '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.',
            },
      status: status,
      code: code is String ? code : null,
    );
  }
}

Future<T> movieLogRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw MovieLogException.fromDio(error);
  }
}

T? readMovieLogResult<T>(
  Response<dynamic> response,
  int status,
  T Function(Object?) parse,
) {
  if (response.statusCode != status || response.data is! Map<String, dynamic>) {
    throw const MovieLogException('서버 응답을 확인할 수 없습니다.');
  }
  final reply = CommonResponse<T>.fromJson(
    response.data as Map<String, dynamic>,
    parse,
  );
  if (!reply.isSuccess) {
    throw MovieLogException(
      reply.message,
      status: response.statusCode,
      code: reply.code,
    );
  }
  return reply.result;
}
