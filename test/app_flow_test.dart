import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';

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

  testWidgets('장르 Chip을 누르면 해당 장르 영화만 보인다', (tester) async {
    await _pumpAppAt(tester, '/movies');

    await tester.tap(find.widgetWithText(ChoiceChip, 'SF'));
    await tester.pumpAndSettle();

    expect(find.text('우주의 끝에서'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
  });

  testWidgets('존재하지 않는 영화 ID는 안내 문구를 보여준다', (tester) async {
    await _pumpAppAt(tester, '/movies/999');

    expect(find.text('영화 정보를 찾을 수 없습니다.'), findsOneWidget);
  });
}
