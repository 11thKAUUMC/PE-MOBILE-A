import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/profile/profile_screen.dart';
import 'package:movielog/start_screen.dart';
import 'package:movielog/theme/app_theme.dart';

void main() {
  testWidgets('시작 화면에 로고와 시작하기 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const StartScreen(),
      ),
    );

    expect(find.text('FLUTTER 1주차'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsNothing);
  });

  testWidgets('프로필 화면에 헤더·통계·장르·수정 버튼이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProfileScreen(),
      ),
    );

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.text('본 영화'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('선호하는 장르'), findsOneWidget);
    expect(find.text('드라마'), findsOneWidget);
    expect(find.text('SF'), findsOneWidget);
    expect(find.text('애니메이션'), findsOneWidget);
    expect(find.text('프로필 수정'), findsOneWidget);
  });
}
