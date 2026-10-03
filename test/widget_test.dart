// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('MovieLog 시작 화면이 표시된다', (tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('FLUTTER 1주차'), findsOneWidget);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });
}
