import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/widgets/movie_rating_input.dart';

Future<void> _pumpAppAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  AppRouter.router.go(location);
  await tester.pumpWidget(const MovieLogApp());
  await tester.pumpAndSettle();
}

void main() {
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

  testWidgets('필터 BottomSheet에서 확인을 눌러야 장르가 적용된다', (tester) async {
    await _pumpAppAt(tester, '/movies');

    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'SF'));
    await tester.tap(find.widgetWithText(CheckboxListTile, '스릴러'));
    await tester.pump();
    expect(find.text('별빛 아래 우리'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('밤의 그림자'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
    expect(
      AppRouter
          .router
          .routeInformationProvider
          .value
          .uri
          .queryParameters['genres'],
      'SF,스릴러',
    );
  });

  testWidgets('선택 없이 확인하면 전체 영화 목록이 보인다', (tester) async {
    await _pumpAppAt(tester, '/movies?genres=SF');
    expect(find.text('별빛 아래 우리'), findsNothing);

    await tester.tap(find.byTooltip('장르 필터'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'SF'));
    await tester.tap(find.widgetWithText(ElevatedButton, '확인'));
    await tester.pumpAndSettle();

    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('탭을 바꿨다 돌아와도 영화 탭의 필터 상태가 유지된다', (tester) async {
    await _pumpAppAt(tester, '/movies?genres=SF');

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

  testWidgets('존재하지 않는 영화 ID는 안내 문구를 보여준다', (tester) async {
    await _pumpAppAt(tester, '/movies/999');

    expect(find.text('영화 정보를 찾을 수 없습니다.'), findsOneWidget);
  });
}
