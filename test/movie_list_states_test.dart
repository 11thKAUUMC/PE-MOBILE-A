import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/movies/movie_grid.dart';
import 'package:movielog/movies/movie_list_empty.dart';
import 'package:movielog/movies/movie_list_error.dart';
import 'package:movielog/movies/movie_list_loading.dart';
import 'package:movielog/movies/movie_list_screen.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';

import 'support/fake_tmdb_movie_service.dart';

Future<void> _pumpScreen(
  WidgetTester tester,
  FakeTmdbLoadMode mode,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final service = FakeTmdbMovieService(mode: mode);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<TmdbMovieService>.value(value: service),
        ChangeNotifierProvider(
          create: (_) => MovieListViewModel(service)..loadInitial(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const MovieListScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('로드 중에는 Loading, 완료 후 Success 영화 Grid가 보인다', (tester) async {
    await _pumpScreen(tester, FakeTmdbLoadMode.success);

    expect(find.byType(MovieListLoading), findsOneWidget);
    expect(find.byType(MovieGrid), findsNothing);

    await tester.pumpAndSettle();
    expect(find.byType(MovieListLoading), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('빈 목록이면 Empty 화면이 보인다', (tester) async {
    await _pumpScreen(tester, FakeTmdbLoadMode.empty);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListEmpty), findsOneWidget);
  });

  testWidgets('실패하면 Error 화면이 보이고 다시 시도하면 성공한다', (tester) async {
    await _pumpScreen(tester, FakeTmdbLoadMode.failure);
    await tester.pumpAndSettle();

    expect(find.byType(MovieListError), findsOneWidget);

    final service =
        tester.element(find.byType(MovieListScreen)).read<TmdbMovieService>()
            as FakeTmdbMovieService;
    service.mode = FakeTmdbLoadMode.success;

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(find.byType(MovieListLoading), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(MovieListError), findsNothing);
    expect(find.byType(MovieGrid), findsOneWidget);
  });
}
