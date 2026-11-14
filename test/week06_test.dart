import 'package:movielog/data/session/learning_member_session.dart';

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/screens/profile_screen.dart';

class Checks extends MemberCheckService {
  Checks() : super(Dio());
  final calls = <String>[];
  final pending = <Completer<bool>>[];
  Future<bool> request(String value) {
    calls.add(value);
    final c = Completer<bool>();
    pending.add(c);
    return c.future;
  }

  @override
  Future<bool> checkNickname(String nickname) => request(nickname);
  @override
  Future<bool> checkEmail(String email) => request(email);
}

class Ratings extends RatingApiService {
  Ratings() : super(Dio());
  List<RatingDto> rows = [];
  int? error;
  Completer<void>? gate;
  @override
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    expect(memberId, 1);
    if (gate != null) await gate!.future;
    if (error != null) {
      throw DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: error),
      );
    }
    return rows;
  }
}

class Movies extends TmdbMovieService {
  Movies() : super(Dio());
  final calls = <int>[];
  bool fail = false;
  @override
  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    calls.add(movieId);
    if (fail) throw DioException(requestOptions: RequestOptions());
    return movieId == 550 ? const TmdbMovieDto(id: 550, title: '파이트 클럽') : null;
  }
}

RatingDto rating(int id, int movieId, String? comment) => RatingDto.fromJson({
  'ratingId': id,
  'movieId': movieId,
  'score': 5,
  'comment': comment,
  'createdAt': '2026-11-05T19:00:00Z',
});
void main() {
  test('필드별 상태, 중복 기억, ABA 응답 무효화, 오류와 dispose', () async {
    final service = Checks();
    final vm = SignUpViewModel(service);
    vm.onNicknameChanged('기존닉네임');
    final first = vm.checkNickname('기존닉네임');
    expect(vm.nicknameCheckStatus, CheckStatus.checking);
    service.pending.last.complete(false);
    await first;
    expect(vm.canCheckNickname, false);
    vm.onNicknameChanged('새닉네임');
    expect(vm.nicknameErrorText, null);
    vm.onNicknameChanged(' 기존닉네임 ');
    expect(vm.nicknameCheckStatus, CheckStatus.duplicated);
    await vm.checkNickname('기존닉네임');
    expect(service.calls.length, 1);
    vm.onEmailChanged('test@example.com');
    final email = vm.checkEmail('test@example.com');
    service.pending.last.complete(true);
    await email;
    expect(vm.emailCheckStatus, CheckStatus.available);
    expect(vm.nicknameCheckStatus, CheckStatus.duplicated);
    vm.onNicknameChanged('새닉네임');
    final old = vm.checkNickname('새닉네임');
    vm.onNicknameChanged('다른닉네임');
    vm.onNicknameChanged('새닉네임');
    service.pending.last.complete(true);
    await old;
    expect(vm.nicknameCheckStatus, CheckStatus.idle);
    final error = vm.checkNickname('새닉네임');
    service.pending.last.completeError(
      DioException(requestOptions: RequestOptions()),
    );
    await error;
    expect(vm.nicknameCheckStatus, CheckStatus.error);
    expect(vm.nicknameErrorText, contains('실패'));
    final disposed = vm.checkNickname('새닉네임');
    vm.dispose();
    service.pending.last.complete(true);
    await disposed;
  });
  test('평점 empty, 400/404, 캐시, TMDB 실패 시 보존과 재시도', () async {
    final service = Ratings();
    final movies = Movies();
    final vm = MyRatingsViewModel(service, movies, 1);
    await vm.load();
    expect(vm.status, MyRatingsLoadStatus.empty);
    for (final status in [400, 404, 500]) {
      service.error = status;
      await vm.load();
      expect(vm.status, MyRatingsLoadStatus.error);
      expect(
        vm.message,
        writeMyRatingsErrorMessage(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: status,
            ),
          ),
        ),
      );
    }
    service.error = null;
    service.rows = [
      rating(1, 550, null),
      rating(2, 550, '다시 봐도 좋다'),
      rating(3, 999, null),
    ];
    await vm.load();
    expect(vm.ratings.length, 3);
    expect(movies.calls, [550, 999]);
    await vm.load();
    expect(movies.calls, [550, 999]);
    final retryMovies = Movies()..fail = true;
    final retry = MyRatingsViewModel(service, retryMovies, 1);
    await retry.load();
    expect(retry.status, MyRatingsLoadStatus.success);
    expect(retry.ratings.length, 3);
    retryMovies.fail = false;
    await retry.load();
    expect(retry.ratings.first.movie?.title, '파이트 클럽');
    service.gate = Completer<void>();
    final pending = vm.load();
    vm.dispose();
    service.gate!.complete();
    await pending;
    retry.dispose();
  });
  testWidgets('회원가입과 평점 상태 및 버튼 너비를 렌더링한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final font = File('/System/Library/Fonts/AppleSDGothicNeo.ttc');
    if (font.existsSync()) {
      await (FontLoader('CaptureKorean')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
    final key = GlobalKey();
    Future<void> show(Widget child) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(
                fontFamily: 'CaptureKorean',
              ),
            ),
            home: child,
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> capture(String name) async {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('docs/week06/design-captures/$name.png');
        file.parent.createSync(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), null);
    }

    final checks = Checks();
    await show(
      Provider<MemberCheckService>.value(
        value: checks,
        child: const SignUpScreen(),
      ),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '스터디닉네임');
    await tester.enterText(fields.at(1), 'study@example.com');
    await capture('01-idle');
    await tester.tap(find.text('중복 확인').first);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await capture('02-checking');
    checks.pending.last.complete(true);
    await tester.pump();
    expect(find.text('사용 가능한 닉네임입니다.'), findsOneWidget);
    await capture('03-available');
    await tester.enterText(fields.at(2), 'password');
    await tester.ensureVisible(find.text('필수 약관에 동의합니다'));
    await tester.tap(find.text('필수 약관에 동의합니다'));
    await tester.ensureVisible(find.text('닉네임'));
    await tester.enterText(fields.at(0), '영화광');
    await tester.pump();
    await tester.tap(find.text('중복 확인').first);
    checks.pending.last.complete(true);
    await tester.pump();
    await tester.enterText(fields.at(1), 'movie@umc.com');
    await tester.pump();
    await tester.tap(find.text('중복 확인').last);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await capture('signup-reference-state');
    checks.pending.last.complete(true);
    await tester.pump();
    await tester.enterText(fields.at(0), '중복닉네임');
    await tester.tap(find.text('중복 확인').first);
    await tester.pump();
    checks.pending.last.complete(false);
    await tester.pump();
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
    await capture('04-duplicated');
    await tester.enterText(fields.at(0), '수정닉네임');
    await tester.pumpAndSettle();
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsNothing);
    await capture('05-invalidated');
    final count = checks.calls.length;
    await tester.enterText(fields.at(0), '중복닉네임');
    await tester.pump();
    expect(checks.calls.length, count);
    expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
    await capture('06-restored');
    await tester.tap(find.text('중복 확인').last);
    await tester.pump();
    checks.pending.last.complete(false);
    await tester.pump();
    expect(find.text('이미 사용 중인 이메일입니다.'), findsOneWidget);
    await capture('07-email-duplicated');
    await tester.enterText(fields.at(1), 'new@example.com');
    await tester.pump();
    await tester.tap(find.text('중복 확인').last);
    await tester.pump();
    checks.pending.last.completeError(
      DioException(requestOptions: RequestOptions()),
    );
    await tester.pump();
    expect(find.text('중복 확인에 실패했습니다. 다시 시도해 주세요.'), findsOneWidget);
    await capture('08-network-error');
    await show(
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MovieLogButton(label: 'null · 내용 너비', onPressed: () {}),
              MovieLogButton(
                label: 'double.infinity · 전체 너비',
                width: double.infinity,
                onPressed: () {},
              ),
              MovieLogButton(label: '고정 120', width: 120, onPressed: () {}),
              const MovieLogButton(label: '비활성', onPressed: null),
              MovieLogButton(
                label: '통신 중',
                isLoading: true,
                onPressed: () => fail('loading tap'),
              ),
            ],
          ),
        ),
      ),
    );
    final buttons = find.byType(MovieLogButton);
    expect(tester.getSize(buttons.at(1)).width, 358);
    expect(tester.getSize(buttons.at(2)).width, 120);
    expect(tester.getSize(buttons.at(0)).width, lessThan(358));
    await capture('09-button-widths');
    final service = Ratings()..gate = Completer<void>();
    final vm = MyRatingsViewModel(service, Movies(), 1);
    final loading = vm.load();
    await show(
      ChangeNotifierProvider.value(value: vm, child: const MyRatingsScreen()),
    );
    await capture('10-ratings-loading');
    service.gate!.complete();
    await loading;
    service.gate = null;
    await tester.pump();
    expect(find.text('아직 등록한 평점이 없습니다.'), findsOneWidget);
    await capture('11-ratings-empty');
    service.error = 404;
    await vm.load();
    await tester.pump();
    await capture('12-ratings-error');
    service.error = null;
    service.rows = [rating(1, 550, '최고의 영화!'), rating(2, 999, null)];
    await vm.load();
    await tester.pump();
    expect(find.text('파이트 클럽'), findsOneWidget);
    expect(find.text('영화 #999'), findsOneWidget);
    expect(find.text('null'), findsNothing);
    await capture('13-ratings-success');
    await tester.pumpWidget(const SizedBox());
    vm.dispose();
    AppRouter.router.go('/my');
    final routeService = Ratings()..rows = [rating(1, 550, '최고의 영화!')];
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => LearningMemberSession()..setMemberId(1),
            ),
            Provider<RatingApiService>.value(value: routeService),
            Provider<TmdbMovieService>.value(value: Movies()),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(
                fontFamily: 'CaptureKorean',
              ),
            ),
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/profile/profile_movielog.jpg'),
        tester.element(find.byType(ProfileScreen)),
      );
    });
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.ensureVisible(find.text('내가 등록한 평점'));
    await capture('14-profile-entry');
    await tester.tap(find.text('내가 등록한 평점'));
    await tester.pumpAndSettle();
    expect(find.byType(MyRatingsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await capture('15-ratings-route');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
