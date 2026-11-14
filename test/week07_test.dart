import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/data/session/learning_member_session.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/widgets/movie_rating_input.dart';
import 'package:movielog/widgets/rating_dialog.dart';

const memberId = 701;
const movie = TmdbMovieDto(id: 550, title: '파이트 클럽');

class _Movies extends TmdbMovieService {
  _Movies() : super(Dio());

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async => [];

  @override
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    List<int>? genreIds,
  }) async => const TmdbMoviePageDto(page: 1, totalPages: 1, results: [movie]);

  @override
  Future<TmdbMovieDto> fetchMovieDetail(int movieId) async => movie;

  @override
  Future<TmdbMovieDto?> findMovieById(int movieId) async => movieId == movie.id
      ? movie
      : TmdbMovieDto(id: movieId, title: '영화 #$movieId');
}

class _Workbook {
  _Workbook() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          calls.add('${request.method} ${request.path}');
          final path = request.path;
          final method = request.method;
          void reply(int status, Object? data) {
            if (status >= 400) {
              handler.reject(
                DioException.badResponse(
                  statusCode: status,
                  requestOptions: request,
                  response: Response(
                    requestOptions: request,
                    statusCode: status,
                    data: data,
                  ),
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: status,
                  data: data,
                ),
              );
            }
          }

          Map<String, dynamic> wrapper(
            int status,
            String message, [
            Object? result,
          ]) => {
            'isSuccess': status < 400,
            'code': 'COMMON$status',
            'message': message,
            'result': result,
          };
          if (path.startsWith('/v6/members/nickname/') ||
              path.startsWith('/v6/members/email/')) {
            reply(200, {'available': true});
            return;
          }
          if (path == '/v6/members' && method == 'POST') {
            final data = request.data as Map<String, dynamic>;
            if (signupStatus == 201) {
              await Future<void>.delayed(const Duration(milliseconds: 350));
            }
            reply(
              signupStatus,
              wrapper(
                signupStatus,
                signupStatus == 409
                    ? '이미 사용 중인 이메일입니다.'
                    : signupStatus == 400
                    ? signupMessage
                    : '가입 완료',
                signupStatus == 201
                    ? {
                        'memberId': memberId,
                        'nickname': data['nickname'],
                        'email': data['email'],
                      }
                    : null,
              ),
            );
            return;
          }
          expect(path, startsWith('/v6/members/$memberId/ratings'));
          switch (method) {
            case 'GET':
              if (failGet) {
                failGet = false;
                reply(500, wrapper(500, '목록 조회 실패'));
              } else {
                reply(200, rows.values.map((row) => Map.of(row)).toList());
              }
            case 'POST':
              final data = request.data as Map<String, dynamic>;
              expect(data['movieId'], movie.id);
              expect(data['score'], isA<int>());
              if (failCreate) {
                reply(409, wrapper(409, '이미 이 영화에 평점을 남기셨습니다.'));
              } else {
                addRow(
                  12,
                  data['movieId'] as int,
                  data['score'] as int,
                  data['comment'] as String?,
                );
                reply(201, wrapper(201, '평점을 등록했습니다.'));
              }
            case 'PATCH':
              final id = int.parse(path.split('/').last);
              final data = request.data as Map<String, dynamic>;
              expect(id, 12);
              expect(data['score'], isA<int>());
              if (patchStatus != 200) {
                reply(patchStatus, wrapper(patchStatus, patchMessage));
              } else {
                addRow(
                  id,
                  rows[id]!['movieId'] as int,
                  data['score'] as int,
                  data['comment'] as String?,
                );
                reply(200, wrapper(200, '수정 완료'));
              }
            case 'DELETE':
              final id = int.parse(path.split('/').last);
              await Future<void>.delayed(const Duration(milliseconds: 500));
              if (id == failedDelete) {
                reply(403, wrapper(403, '평점을 삭제할 권한이 없습니다.'));
              } else {
                rows.remove(id);
                reply(204, null);
              }
            default:
              fail('Unexpected request');
          }
        },
      ),
    );
  }

  final dio = Dio();
  final calls = <String>[];
  final rows = <int, Map<String, dynamic>>{};
  int signupStatus = 409;
  String signupMessage = '';
  int patchStatus = 200;
  String patchMessage = '';
  int? failedDelete;
  bool failGet = false;
  bool failCreate = true;

  void addRow(int id, int movieId, int score, String? comment) {
    rows[id] = {
      'ratingId': id,
      'movieId': movieId,
      'score': score,
      'comment': comment,
      'createdAt': '2026-11-14T00:00:00Z',
    };
  }
}

void main() {
  testWidgets('가입부터 평점 CRUD와 부분 실패까지 화면과 요청을 확인한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final font = File('/System/Library/Fonts/AppleSDGothicNeo.ttc');
    if (font.existsSync()) {
      await (FontLoader('W7Korean')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
    final workbook = _Workbook();
    addTearDown(workbook.dio.close);
    final session = LearningMemberSession();
    addTearDown(session.dispose);
    final ratings = RatingApiService(workbook.dio);
    final boundary = GlobalKey();
    SharedPreferences.setMockInitialValues({});
    final router = AppRouter.router;
    router.go('/signup');
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MultiProvider(
          providers: [
            Provider(create: (_) => SignUpService(workbook.dio)),
            Provider.value(value: ratings),
            Provider<TmdbMovieService>(create: (_) => _Movies()),
            ChangeNotifierProvider.value(value: session),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(fontFamily: 'W7Korean'),
            ),
            routerConfig: router,
          ),
        ),
      ),
    );
    Future<void> settle() =>
        tester.pumpAndSettle(const Duration(milliseconds: 100));
    Future<void> tap(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
    }

    Future<void> capture(String name) async {
      await tester.pump(const Duration(milliseconds: 180));
      expect(tester.takeException(), isNull);
      if (!const bool.fromEnvironment('WEEK07_CAPTURE')) return;
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('docs/week07/captures/$name.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await settle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '칠주차테스트');
    await settle();
    await tester.tap(find.text('중복 확인').first);
    await settle();
    expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);
    await tester.enterText(fields.at(0), '칠주차수정');
    await settle();
    expect(find.text('사용 가능한 닉네임입니다.'), findsNothing);
    await capture('01-invalidated');
    await tester.tap(find.text('중복 확인').first);
    await settle();
    await tester.enterText(fields.at(1), 'week7-example@example.com');
    await settle();
    await tester.tap(find.text('중복 확인').last);
    await settle();
    await tester.enterText(fields.at(2), 'OnlyForFixture7!');
    await settle();
    await tap('필수 약관에 동의합니다');
    await tap('가입하기');
    await settle();
    expect(find.text('이미 사용 중인 이메일입니다.'), findsOneWidget);
    expect(find.text('사용 가능한 이메일입니다.'), findsNothing);
    expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '가입하기'))
          .onPressed,
      isNull,
    );
    await capture('02-signup-conflict');
    await tester.tap(find.text('중복 확인').last);
    await settle();
    workbook.signupStatus = 400;
    workbook.signupMessage = '비밀번호 형식이 올바르지 않습니다.';
    await tap('가입하기');
    await settle();
    expect(
      tester.widget<TextFormField>(fields.at(2)).controller!.text,
      isNotEmpty,
    );
    await tester.ensureVisible(fields.at(2));
    expect(find.text(workbook.signupMessage), findsOneWidget);
    await capture('03-signup-password-error');
    workbook.signupMessage = '올바른 이메일 형식이 아닙니다.';
    await tap('가입하기');
    await settle();
    expect(find.text(workbook.signupMessage), findsOneWidget);
    workbook.signupStatus = 201;
    await tap('가입하기');
    await tester.binding.handlePopRoute();
    expect(find.byType(SignUpScreen), findsOneWidget);
    await capture('03-signup-submitting');
    await settle();
    expect(session.memberId, memberId);
    expect(router.routeInformationProvider.value.uri.path, '/movies');
    expect(find.byType(SnackBar), findsNothing);
    await capture('04-signup-success');

    await tap('파이트 클럽');
    await settle();
    expect(find.byType(MovieDetailScreen), findsOneWidget);
    await tap('평점 남기기');
    await settle();
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '확인'))
          .onPressed,
      isNull,
    );
    await capture('05-rating-dialog-disabled');
    final starBar = tester.getRect(find.byType(MovieRatingInput));
    await tester.tapAt(Offset(starBar.left + 126, starBar.center.dy));
    await tester.enterText(find.byType(TextField).last, '다시 봐도 좋아요');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle();
    await capture('06-rating-dialog-ready');
    await tap('확인');
    await settle();
    expect(find.text('이미 이 영화에 평점을 남기셨습니다.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      '다시 봐도 좋아요',
    );
    await capture('07-write-failed-input-retained');
    workbook.failCreate = false;
    await tap('확인');
    await settle();
    expect(find.text('평점을 등록했습니다.'), findsOneWidget);
    await capture('08-create-success');
    router.go('/my');
    await settle();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/profile/profile_movielog.jpg'),
        tester.element(find.text('내가 등록한 평점')),
      );
    });
    await settle();
    await tester.ensureVisible(find.text('내가 등록한 평점'));
    await capture('08-profile-entry');
    await tap('내가 등록한 평점');
    await settle();
    expect(find.text('파이트 클럽'), findsOneWidget);
    expect(find.text('별점 4 / 5'), findsOneWidget);
    await capture('09-create-fetch');

    await tap('수정');
    await settle();
    expect(
      tester.widget<RatingDialog>(find.byType(RatingDialog)).initialScore,
      4,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      '다시 봐도 좋아요',
    );
    await capture('10-edit-prefilled');
    await tester.enterText(find.byType(TextField).last, '수정한 코멘트');
    FocusManager.instance.primaryFocus?.unfocus();
    for (final error in [
      (400, '별점 범위 오류'),
      (403, '평점 수정 권한 없음'),
      (404, '존재하지 않는 평점입니다.'),
    ]) {
      workbook.patchStatus = error.$1;
      workbook.patchMessage = error.$2;
      await tap('확인');
      await settle();
      expect(find.text(error.$2), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        '수정한 코멘트',
      );
      await capture('11-error-${error.$1}');
    }
    workbook.patchStatus = 200;
    await tap('확인');
    await settle();
    expect(find.text('수정한 코멘트'), findsOneWidget);
    await capture('12-edit-fetch');
    await tap('수정');
    await settle();
    workbook.failGet = true;
    await tap('확인');
    await settle();
    expect(find.textContaining('조회만 다시 시도'), findsWidgets);
    await capture('13-refresh-failed');
    final writes = workbook.calls
        .where((call) => call.startsWith('PATCH'))
        .length;
    await tap('다시 시도');
    await settle();
    expect(
      workbook.calls.where((call) => call.startsWith('PATCH')).length,
      writes,
    );
    expect(workbook.calls.last, 'GET /v6/members/701/ratings');
    await capture('14-get-only-retry');

    await tap('삭제');
    await settle();
    await capture('15-delete-confirm');
    await tap('취소');
    await settle();
    expect(workbook.calls.where((call) => call.startsWith('DELETE')), isEmpty);
    await capture('16-delete-cancelled');
    await tap('삭제');
    await settle();
    await tap('삭제');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('평점을 삭제할까요?'), findsOneWidget);
    await capture('17-single-delete-busy');
    await settle();
    expect(find.text('아직 등록한 평점이 없습니다.'), findsOneWidget);
    expect(find.text('평점을 삭제했습니다.'), findsOneWidget);
    await capture('18-delete-empty');

    workbook.addRow(12, 550, 5, '좋은 영화였어요');
    workbook.addRow(13, 680, 4, '다시 봐도 좋아요');
    workbook.addRow(14, 13, 3, null);
    router.go('/movies/550');
    await settle();
    router.go('/my/ratings');
    await settle();
    await capture('19-edit-entry');
    await tap('편집');
    await settle();
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.tap(find.byType(Checkbox).at(1));
    await settle();
    await capture('20-multi-selection');
    await tap('선택한 2개 삭제');
    await settle();
    workbook.failedDelete = 13;
    await tap('삭제');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('평점 2개를 삭제할까요?'), findsNothing);
    expect(find.byType(ModalBarrier), findsWidgets);
    await capture('21-multi-deleting');
    await settle();
    expect(find.text('선택한 2개 중 1개를 삭제하지 못했습니다.'), findsOneWidget);
    expect(workbook.rows.keys, unorderedEquals([13, 14]));
    await capture('22-multi-partial');
    if (const bool.fromEnvironment('WEEK07_CAPTURE')) {
      File('docs/week07/simulated-requests.txt')
          .writeAsStringSync(workbook.calls.join('\n'));
    }
  });
}
