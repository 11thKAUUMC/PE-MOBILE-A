import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/widgets/movie_rating_input.dart';

import 'support/fake_tmdb_movie_service.dart';

Future<void> _go(WidgetTester tester, String location) async {
  final context = AppRouter.rootNavigatorKey.currentContext;
  expect(context, isNotNull);
  GoRouter.of(context!).go(location);
  await tester.pumpAndSettle();
}

class _FakeSignUpService extends SignUpService {
  _FakeSignUpService() : super(Dio());

  @override
  Future<bool> checkNickname(String nickname) async => true;

  @override
  Future<bool> checkEmail(String email) async => true;

  @override
  Future<CommonResponse<SignUpResult>> signUp(
    CreateMemberRequest request,
  ) async {
    return CommonResponse<SignUpResult>(
      isSuccess: true,
      code: 'CREATED',
      message: 'ok',
      result: SignUpResult(
        memberId: 42,
        email: request.email,
        nickname: request.nickname,
      ),
    );
  }
}

class _FakeMemberApiService extends MemberApiService {
  _FakeMemberApiService() : super(Dio());

  @override
  Future<MemberInfo> fetchMe() async {
    return MemberInfo(
      email: 'movie@example.com',
      nickname: '무비러버',
      createdAt: DateTime(2026, 10, 10),
    );
  }

  @override
  Future<MemberInfo> updateNickname(String nickname) async {
    return MemberInfo(
      email: 'movie@example.com',
      nickname: nickname,
      createdAt: DateTime(2026, 10, 10),
    );
  }
}

class _FakeRatingApiService extends RatingApiService {
  _FakeRatingApiService() : super(Dio(), Dio());

  @override
  Future<List<RatingDto>> fetchMyRatings(int memberId) async => const [];

  @override
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    return RatingDto(
      ratingId: 1,
      movieId: request.movieId,
      score: request.score,
      comment: request.comment,
      createdAt: DateTime(2026, 11, 22),
    );
  }

  @override
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    return RatingDto(
      ratingId: ratingId,
      movieId: 1,
      score: score,
      comment: comment,
      createdAt: DateTime(2026, 11, 22),
    );
  }

  @override
  Future<void> deleteRating(int ratingId) async {}
}

Future<void> _pumpSignedInApp(
  WidgetTester tester, {
  String? goTo,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final storage = InMemoryTokenStorage();
  await storage.saveAccessToken('test-token');

  await tester.pumpWidget(
    MovieLogApp(
      tmdbMovieService: FakeTmdbMovieService(),
      signUpService: _FakeSignUpService(),
      ratingApiService: _FakeRatingApiService(),
      memberApiService: _FakeMemberApiService(),
      tokenStorage: storage,
    ),
  );
  await tester.pumpAndSettle();

  if (goTo != null) {
    await _go(tester, goTo);
  }
}

Future<void> _pumpSignedOutApp(WidgetTester tester, {String? goTo}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MovieLogApp(
      tmdbMovieService: FakeTmdbMovieService(),
      signUpService: _FakeSignUpService(),
      ratingApiService: _FakeRatingApiService(),
      memberApiService: _FakeMemberApiService(),
      tokenStorage: InMemoryTokenStorage(),
    ),
  );
  await tester.pumpAndSettle();

  if (goTo != null) {
    await _go(tester, goTo);
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('시작 세션 확인 후 로그인 화면으로 이동한다', (tester) async {
    await _pumpSignedOutApp(tester);
    expect(find.text('MovieLog에 로그인'), findsOneWidget);
  });

  testWidgets('회원가입 후 로그인 화면으로 이동한다', (tester) async {
    await _pumpSignedOutApp(tester, goTo: '/register');

    expect(find.text('회원가입'), findsWidgets);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '무비러버');
    await tester.enterText(fields.at(1), 'movie@example.com');
    await tester.enterText(fields.at(2), 'Password1!');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    final checkButtons = find.widgetWithText(ElevatedButton, '중복 확인');
    await tester.tap(checkButtons.at(0));
    await tester.pumpAndSettle();
    await tester.tap(checkButtons.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();

    expect(find.text('MovieLog에 로그인'), findsOneWidget);
  });

  testWidgets('홈 추천 카드에서 상세로 이동하고 뒤로 돌아온다', (tester) async {
    await _pumpSignedInApp(tester);

    await tester.tap(find.text('상세보기'));
    await tester.pumpAndSettle();

    expect(find.text('Cinema Archive'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('NavigationBar 선택 상태와 화면이 일치한다', (tester) async {
    await _pumpSignedInApp(tester);

    await tester.tap(find.text('영화'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('내 프로필'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
  });

  testWidgets('목록 카드를 누르면 Path Parameter의 영화 상세가 보인다', (tester) async {
    await _pumpSignedInApp(tester, goTo: '/movies');

    await tester.tap(find.text('도시의 밤'));
    await tester.pumpAndSettle();

    expect(find.text('Cinema Archive'), findsOneWidget);
    expect(find.textContaining('TMDB #2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('장르 Chip을 누르면 목록이 갱신된다', (tester) async {
    await _pumpSignedInApp(tester, goTo: '/movies');

    await tester.tap(find.widgetWithText(ChoiceChip, '액션'));
    await tester.pumpAndSettle();

    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '액션'))
          .selected,
      isTrue,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, '전체'));
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('탭을 바꿨다 돌아와도 영화 탭의 장르 상태가 유지된다', (tester) async {
    await _pumpSignedInApp(tester, goTo: '/movies');
    await tester.tap(find.widgetWithText(ChoiceChip, '액션'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('영화'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '액션'))
          .selected,
      isTrue,
    );
  });

  testWidgets('상세 화면에 TMDB 평점이 읽기 전용으로 보인다', (tester) async {
    await _pumpSignedInApp(tester);
    await tester.tap(find.text('상세보기'));
    await tester.pumpAndSettle();

    final indicator = tester.widget<RatingBarIndicator>(
      find.byType(RatingBarIndicator),
    );
    expect(indicator.rating, closeTo(4.1, 0.01));
    expect(find.text('8.2'), findsOneWidget);
  });

  testWidgets('즐겨찾기 추가·삭제 결과를 Snackbar와 아이콘으로 보여준다', (tester) async {
    await _pumpSignedInApp(tester);
    await tester.tap(find.text('상세보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('즐겨찾기'));
    await tester.pump();
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tap(find.text('즐겨찾기'));
    await tester.pump();
    expect(find.text('즐겨찾기에서 삭제했습니다.'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('평점 Dialog는 별을 선택해야 확인 버튼이 활성화된다', (tester) async {
    await _pumpSignedInApp(tester);
    await tester.tap(find.text('상세보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieRatingInput), findsOneWidget);
    expect(find.text('코멘트를 남겨보세요 (선택)'), findsOneWidget);
    ElevatedButton confirmButton() =>
        tester.widget(find.widgetWithText(ElevatedButton, '확인'));
    expect(confirmButton().onPressed, isNull);

    await tester.tap(
      find
          .descendant(
            of: find.byType(MovieRatingInput),
            matching: find.byIcon(Icons.star),
          )
          .at(3),
    );
    await tester.pump();
    expect(confirmButton().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('평점을 등록했습니다'), findsOneWidget);
  });

  testWidgets('비로그인 상태에서 보호 화면은 로그인으로 보낸다', (tester) async {
    await _pumpSignedOutApp(tester, goTo: '/home');
    expect(find.text('MovieLog에 로그인'), findsOneWidget);
  });

  for (final location in ['/home', '/movies', '/my']) {
    testWidgets('작은 화면에서도 $location 화면에 Overflow가 없다', (tester) async {
      await _pumpSignedInApp(tester, goTo: location);
      tester.view.physicalSize = const Size(360, 640);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('존재하지 않는 영화 ID는 안내 문구를 보여준다', (tester) async {
    await _pumpSignedInApp(tester, goTo: '/movies/999');

    expect(find.text('영화를 불러오지 못했습니다.'), findsOneWidget);
  });

  testWidgets('마이페이지에 가입일과 닉네임이 보인다', (tester) async {
    await _pumpSignedInApp(tester, goTo: '/my');

    expect(find.text('무비러버'), findsOneWidget);
    expect(find.text('2026.10.10 가입'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
  });
}
