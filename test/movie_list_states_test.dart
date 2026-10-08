import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:movielog/movies/movie_grid.dart';
import 'package:movielog/movies/movie_list_empty.dart';
import 'package:movielog/movies/movie_list_error.dart';
import 'package:movielog/movies/movie_list_loading.dart';
import 'package:movielog/movies/movie_list_screen.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/theme/app_theme.dart';

Future<void> _pumpScreen(WidgetTester tester, MovieLoadMode mode) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MovieListScreen(loadMode: mode),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('로드 중에는 Loading, 완료 후 Success 영화 Grid가 보인다', (tester) async {
    await _pumpScreen(tester, MovieLoadMode.success);

    expect(find.byType(MovieListLoading), findsOneWidget);
    expect(find.byType(MovieGrid), findsNothing);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(MovieListLoading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(MovieListLoading), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('빈 목록이면 Empty 화면이 보인다', (tester) async {
    await _pumpScreen(tester, MovieLoadMode.empty);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListEmpty), findsOneWidget);
    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);
  });

  testWidgets('실패하면 Error 화면이 보이고 다시 시도하면 성공한다', (tester) async {
    await _pumpScreen(tester, MovieLoadMode.failure);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListError), findsOneWidget);
    expect(find.text(MovieListError.defaultMessage), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(find.byType(MovieListLoading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(MovieListError), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
  });

  testWidgets('응답이 Timeout보다 늦으면 지연 안내 Error 화면이 보인다', (tester) async {
    await _pumpScreen(tester, MovieLoadMode.timeout);
    await tester.pumpAndSettle();

    expect(find.text(MovieListError.timeoutMessage), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('목록을 당기면 새로고침된다', (tester) async {
    await _pumpScreen(tester, MovieLoadMode.success);
    await tester.pumpAndSettle();

    await tester.fling(find.byType(MovieGrid), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    expect(find.byType(MovieGrid), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
  });
}
