import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movielog/models/movie_sort.dart';
import 'package:movielog/movie_log_app.dart';
import 'package:movielog/movies/movie_sort_menu.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/services/movie_preference.dart';
import 'package:movielog/widgets/movie_rating_input.dart';

Future<void> _pumpAppAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  AppRouter.router.go(location);
  await tester.pumpWidget(const MovieLogApp());
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('시작 → 회원가입 → 홈으로 이동하고 뒤로 가기가 막혀 있다', (tester) async {
    await _pumpAppAt(tester, '/start');

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('회원가입'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(AppRouter.router.canPop(), isFalse);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '무비러버');
    await tester.enterText(fields.at(1), 'movie@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsOneWidget);
    expect(AppRouter.router.canPop(), isFalse);
  });

  testWidgets('홈 추천 카드에서 상세로 이동하고 뒤로 돌아온다', (tester) async {
    await _pumpAppAt(tester, '/home');

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
    await _pumpAppAt(tester, '/home');

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
    await _pumpAppAt(tester, '/movies');

    await tester.tap(find.text('우주의 끝에서'));
    await tester.pumpAndSettle();

    expect(find.text('Cinema Archive'), findsOneWidget);
    expect(find.textContaining('138분'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('장르 Chip을 누르면 목록이 갱신되고 선택 장르가 저장된다', (tester) async {
    await _pumpAppAt(tester, '/movies');

    await tester.tap(find.widgetWithText(ChoiceChip, 'SF'));
    await tester.pumpAndSettle();

    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
    expect(
      await SharedPreferencesAsync().getString(
        MoviePreference.selectedGenreKey,
      ),
      'SF',
    );

    await tester.tap(find.widgetWithText(ChoiceChip, '전체'));
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('저장된 장르와 정렬 방식이 앱 재실행 후 복원된다', (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          MoviePreference.selectedGenreKey: 'SF',
          MoviePreference.selectedSortKey: 'rating',
        });

    await _pumpAppAt(tester, '/movies');

    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'SF')).selected,
      isTrue,
    );
    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
    expect(
      tester.widget<MovieSortMenu>(find.byType(MovieSortMenu)).selected,
      MovieSort.rating,
    );
  });

  testWidgets('탭을 바꿨다 돌아와도 영화 탭의 장르 상태가 유지된다', (tester) async {
    await _pumpAppAt(tester, '/movies');
    await tester.tap(find.widgetWithText(ChoiceChip, 'SF'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('영화'));
    await tester.pumpAndSettle();

    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
  });

  testWidgets('상세 화면에 평균 평점 4.5가 읽기 전용으로 보인다', (tester) async {
    await _pumpAppAt(tester, '/movies/1');

    final indicator = tester.widget<RatingBarIndicator>(
      find.byType(RatingBarIndicator),
    );
    expect(indicator.rating, 4.5);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('즐겨찾기 추가·삭제 결과를 Snackbar와 아이콘으로 보여준다', (tester) async {
    await _pumpAppAt(tester, '/movies/1');

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
    await _pumpAppAt(tester, '/movies/1');

    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieRatingInput), findsOneWidget);
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
    expect(find.byType(Dialog), findsNothing);
    expect(find.textContaining('내 평점'), findsOneWidget);
  });

  testWidgets('평점 Dialog에서 초기화 후 다시 선택할 수 있다', (tester) async {
    await _pumpAppAt(tester, '/movies/1');

    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();

    Finder stars() => find.descendant(
      of: find.byType(MovieRatingInput),
      matching: find.byIcon(Icons.star),
    );
    ElevatedButton confirmButton() =>
        tester.widget(find.widgetWithText(ElevatedButton, '확인'));

    await tester.tap(stars().at(4));
    await tester.pump();
    expect(confirmButton().onPressed, isNotNull);

    await tester.tap(find.text('초기화하고 다시 선택하기'));
    await tester.pump();
    expect(find.text('별을 눌러 평점을 선택해주세요'), findsOneWidget);
    expect(confirmButton().onPressed, isNull);

    await tester.tap(stars().at(1));
    await tester.pump();
    expect(confirmButton().onPressed, isNotNull);
  });

  for (final location in ['/home', '/movies', '/movies/1', '/my']) {
    testWidgets('작은 화면에서도 $location 화면에 Overflow가 없다', (tester) async {
      await _pumpAppAt(tester, location);
      tester.view.physicalSize = const Size(360, 640);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('존재하지 않는 영화 ID는 안내 문구를 보여준다', (tester) async {
    await _pumpAppAt(tester, '/movies/999');

    expect(find.text('영화 정보를 찾을 수 없습니다.'), findsOneWidget);
  });
}
