import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movielog/auth/splash_screen.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/profile/profile_screen.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/auth_view_model.dart';

void main() {
  testWidgets('스플래시 화면에 로고와 8주차 문구가 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );

    expect(find.text('FLUTTER 8주차'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsNothing);
  });

  testWidgets('프로필 화면에 헤더·통계·장르·수정 버튼이 보인다', (WidgetTester tester) async {
    final auth = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(Dio()),
      InMemoryTokenStorage(),
    );
    auth.status = AuthStatus.signedIn;
    auth.memberStatus = MemberLoadStatus.success;
    auth.member = MemberInfo(
      email: 'movie@example.com',
      nickname: '무비러버',
      createdAt: DateTime(2026, 10, 10),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: auth,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProfileScreen(),
        ),
      ),
    );

    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.text('무비러버'), findsOneWidget);
    expect(find.text('2026.10.10 가입'), findsOneWidget);
    expect(find.text('본 영화'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('선호하는 장르'), findsOneWidget);
    expect(find.text('드라마'), findsOneWidget);
    expect(find.text('SF'), findsOneWidget);
    expect(find.text('애니메이션'), findsOneWidget);
    expect(find.text('프로필 수정'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
  });
}
