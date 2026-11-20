import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/auth_interceptor.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/login_models.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';

import 'support/memory_token_storage.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final FutureOr<ResponseBody> Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody reply(int status, String code, [Object? result]) =>
    ResponseBody.fromString(
      jsonEncode({
        'isSuccess': status < 400,
        'code': code,
        'message': code,
        'result': result,
      }),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

const login = LoginRequest(email: 'fixture@example.com', password: 'fixture');
const member = {
  'email': 'fixture@example.com',
  'nickname': '스터디',
  'createdAt': '2026-10-10T02:00:00Z',
};
const missingMovieRating = {
  'ratingId': 1,
  'movieId': 999,
  'score': 4,
  'comment': '시사회',
  'createdAt': '2026-11-21T02:00:00Z',
};

void main() {
  late Dio publicClient;
  late Dio protectedClient;
  late AuthViewModel auth;
  late MemberApiService members;
  late MemoryTokenStorage storage;
  late RatingApiService ratings;
  late MyRatingsViewModel list;
  late List<RequestOptions> requests;
  int tokenId = 0;

  void init({
    String? initial,
    int loginStatus = 200,
    required FutureOr<ResponseBody> Function(RequestOptions) protected,
  }) {
    storage = MemoryTokenStorage(initial);
    requests = [];
    publicClient = createMovieLogClient()
      ..httpClientAdapter = _Adapter((options) {
        requests.add(options);
        expect(options.headers['Authorization'], isNull);
        if (options.path == '/v7/auth/login') {
          return loginStatus == 200
              ? reply(200, 'COMMON200', {
                  'nickname': '스터디',
                  'accessToken': 'fixture-${++tokenId}',
                })
              : reply(401, 'AUTH401_1');
        }
        return ResponseBody.fromString(
          '[]',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    protectedClient =
        createMovieLogClient(
            auth: AuthInterceptor(
              session: () => auth.credentials,
              onExpired: (version) => auth.expireSession(version),
            ),
          )
          ..httpClientAdapter = _Adapter((options) {
            requests.add(options);
            return protected(options);
          });
    members = MemberApiService(protectedClient);
    auth = AuthViewModel(storage, AuthApiService(publicClient), members);
    ratings = RatingApiService(publicClient, protectedClient);
    list = MyRatingsViewModel(ratings, auth);
    addTearDown(() {
      list.dispose();
      auth.dispose();
      publicClient.close(force: true);
      protectedClient.close(force: true);
    });
  }

  test('재시작 중 보호 경로를 막고 네트워크 오류 뒤 토큰을 다시 검증한다', () async {
    final gate = Completer<ResponseBody>();
    var first = true;
    init(
      initial: 'fixture-restore',
      protected: (request) {
        expect(request.headers['Authorization'], 'Bearer fixture-restore');
        if (first) {
          first = false;
          return gate.future;
        }
        return reply(200, 'COMMON200', member);
      },
    );

    final restoring = auth.restoreSession();
    expect(authRedirect(auth.status, '/my/profile/edit'), '/start');
    gate.complete(reply(503, 'COMMON503'));
    await restoring;
    expect(auth.status, AuthStatus.retryRequired);
    expect(storage.deletions, 0);
    await auth.restoreSession();
    expect(auth.status, AuthStatus.signedIn);
    expect(auth.member?.nickname, '스터디');
    await auth.loadMember();
    expect(requests.length, 2);
    await auth.logout();
    expect(storage.token, isNull);
    expect(auth.member, isNull);
    expect(authRedirect(auth.status, '/my/profile/edit'), '/login');
    expect(auth.consumeSessionExpired(), isFalse);
  });

  test('내 정보 로딩 실패 뒤 세션을 유지하고 다시 조회한다', () async {
    final gate = Completer<ResponseBody>();
    var first = true;
    init(
      protected: (_) {
        if (first) {
          first = false;
          return gate.future;
        }
        return reply(200, 'COMMON200', member);
      },
    );
    await auth.restoreSession();
    expect(await auth.login(login), isTrue);
    final loading = auth.loadMember();
    expect(auth.memberStatus, MemberLoadStatus.loading);
    gate.complete(reply(503, 'COMMON503'));
    await loading;
    expect(auth.memberStatus, MemberLoadStatus.error);
    expect(auth.status, AuthStatus.signedIn);
    expect(storage.deletions, 0);
    expect(storage.token, isNotNull);
    await auth.loadMember(force: true);
    expect(auth.memberStatus, MemberLoadStatus.success);
    expect(auth.member?.email, 'fixture@example.com');
  });

  test('공개 로그인 401은 입력 오류로 남기고 저장소를 지우지 않는다', () async {
    init(loginStatus: 401, protected: (_) => throw StateError('unexpected'));
    await auth.restoreSession();
    expect(await auth.login(login), isFalse);
    expect(auth.loginError, '이메일 또는 비밀번호가 올바르지 않아요.');
    expect(auth.status, AuthStatus.signedOut);
    expect(storage.deletions, 0);
    expect(auth.consumeSessionExpired(), isFalse);
  });

  test('보호 경로 403은 유지하고 동시 만료는 한 번 처리한다', () async {
    init(
      initial: 'fixture-token',
      protected: (request) {
        expect(request.headers['Authorization'], 'Bearer fixture-token');
        if (request.path == '/v7/members/me') {
          return reply(200, 'COMMON200', member);
        }
        if (request.method == 'PATCH') return reply(403, 'RATING403_1');
        return reply(401, 'AUTH401_4');
      },
    );
    await auth.restoreSession();
    await expectLater(
      ratings.updateRating(1, RatingInput(score: 3)),
      throwsA(
        isA<MovieLogException>().having((e) => e.code, 'code', 'RATING403_1'),
      ),
    );
    expect(auth.status, AuthStatus.signedIn);
    await Future.wait([
      for (final id in [1, 2])
        expectLater(
          ratings.deleteRating(id),
          throwsA(isA<MovieLogException>()),
        ),
    ]);
    expect(storage.deletions, 1);
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.consumeSessionExpired(), isTrue);
    expect(auth.consumeSessionExpired(), isFalse);
  });

  test('이전 계정의 늦은 401과 쓰기 성공이 새 계정에 반영되지 않는다', () async {
    final stale401 = Completer<ResponseBody>();
    final staleWrite = Completer<ResponseBody>();
    final bothStarted = Completer<void>();
    init(
      initial: 'fixture-old',
      protected: (request) {
        if (requests.length == 3) bothStarted.complete();
        return switch (request.method) {
          'DELETE' => stale401.future,
          'POST' => staleWrite.future,
          _ => reply(200, 'COMMON200', member),
        };
      },
    );
    await auth.restoreSession();
    final late401 = expectLater(
      ratings.deleteRating(1),
      throwsA(isA<MovieLogException>()),
    );
    final lateWrite = expectLater(
      list.createRating(
        const TmdbMovieDto(id: 550, title: '영화'),
        RatingInput(score: 4),
      ),
      throwsA(isA<MovieLogException>()),
    );
    await bothStarted.future;
    await auth.logout();
    expect(await auth.login(login), isTrue);
    stale401.complete(reply(401, 'AUTH401_3'));
    staleWrite.complete(reply(201, 'COMMON201', missingMovieRating));
    await Future.wait([late401, lateWrite]);
    expect(auth.status, AuthStatus.signedIn);
    expect(storage.deletions, 1);
    expect(list.ratings, isEmpty);
    expect(auth.consumeSessionExpired(), isFalse);
  });

  test('공개/외부 요청은 JWT를 떼고 평점은 응답 영화 ID로 결합한다', () async {
    init(
      initial: 'fixture-token',
      protected: (request) {
        return switch (request.path) {
          '/v7/members/me' when request.uri.host == 'workbook.devnoco.com' =>
            reply(200, 'COMMON200', member),
          '/v7/ratings' => reply(201, 'COMMON201', missingMovieRating),
          '/v7/ratings/1' => reply(200, 'COMMON200', {
            ...missingMovieRating,
            'score': 5,
            'comment': null,
          }),
          _ => reply(200, 'COMMON200'),
        };
      },
    );
    await auth.restoreSession();
    await ratings.fetchPublicRatings(5);
    await protectedClient.get('/v7/members/5/ratings');
    await protectedClient.get('https://example.com/v7/members/me');
    await list.createRating(
      const TmdbMovieDto(id: 550, title: '파이트 클럽'),
      RatingInput(score: 4),
    );
    expect(requests[2].headers['Authorization'], isNull);
    expect(requests[3].headers['Authorization'], isNull);
    expect(requests[4].headers['Authorization'], 'Bearer fixture-token');
    expect(requests[4].data, {'movieId': 550, 'score': 4});
    expect(list.ratings.single.rating.movieId, 999);
    expect(list.ratings.single.movie, isNull);
    await list.updateRating(1, RatingInput(score: 5));
    expect(requests.last.data, {'score': 5, 'comment': null});
    expect(list.ratings.single.rating.score, 5);
  });
}
