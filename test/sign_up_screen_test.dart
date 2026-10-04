import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movielog/sign_up/sign_up_screen.dart';
import 'package:movielog/theme/app_theme.dart';

Widget _app({EdgeInsets viewInsets = EdgeInsets.zero}) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
      child: child!,
    ),
    home: const SignUpScreen(),
  );
}

ElevatedButton _submitButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '가입하기'));

void main() {
  testWidgets('입력 전에는 가입 버튼이 비활성화된다', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('회원가입'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('잘못된 입력에는 한국어 오류 메시지가 보인다', (tester) async {
    await tester.pumpWidget(_app());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'a');
    await tester.enterText(fields.at(1), 'test@');
    await tester.enterText(fields.at(2), '123');
    await tester.pump();

    expect(find.text('닉네임은 2자 이상이어야 합니다.'), findsOneWidget);
    expect(find.text('올바른 이메일 형식이 아닙니다.'), findsOneWidget);
    expect(find.text('비밀번호는 8자 이상이어야 합니다.'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
  });

  testWidgets('모든 입력이 유효하고 약관에 동의하면 버튼이 활성화된다', (tester) async {
    await tester.pumpWidget(_app());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '무비러버');
    await tester.enterText(fields.at(1), 'movie@example.com');
    await tester.enterText(fields.at(2), 'password123');
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(_submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('작은 화면에서 키보드가 열려도 Overflow가 없다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(viewInsets: const EdgeInsets.only(bottom: 300)),
    );

    expect(tester.takeException(), isNull);
  });
}
