import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/widgets/movie_card.dart';
import 'package:movielog/widgets/movie_grid.dart';
import 'package:movielog/widgets/movie_list_empty.dart';
import 'package:movielog/widgets/movie_list_error.dart';
import 'package:movielog/widgets/movie_list_loading.dart';

void main() {
  Future<void> render(WidgetTester tester, Widget widget) async {
    await tester.binding.setSurfaceSize(const Size(400, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  }

  testWidgets('Loading은 Skeleton 목록과 접근성 로딩 안내를 표시한다', (tester) async {
    final semantics = tester.ensureSemantics();
    await render(tester, const MovieListLoading());

    expect(find.byType(GridView), findsOneWidget);
    expect(find.bySemanticsLabel('영화를 불러오는 중이에요.'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('Empty는 빈 목록 안내를 표시한다', (tester) async {
    await render(tester, const MovieListEmpty());

    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
    expect(find.text('다시 시도'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Error는 오류 안내를 표시하고 버튼 클릭 시 재시도를 호출한다', (tester) async {
    var retryCount = 0;
    await render(tester, MovieListError(onRetry: () => retryCount++));

    expect(find.text('영화를 불러오지 못했습니다.'), findsOneWidget);
    expect(find.text('잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(retryCount, 0);
    await tester.tap(find.widgetWithText(FilledButton, '다시 시도'));
    await tester.pump();
    expect(retryCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Timeout은 일반 오류와 구분되는 안내를 표시한다', (tester) async {
    await render(tester, MovieListError(onRetry: () {}, isTimeout: true));

    expect(find.text('응답 시간이 초과되었습니다.'), findsOneWidget);
    expect(find.text('응답이 늦어지고 있어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('영화를 불러오지 못했습니다.'), findsNothing);
    expect(find.widgetWithText(FilledButton, '다시 시도'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Success는 전달받은 영화의 제목과 평점 및 포스터를 표시한다', (tester) async {
    final selectedMovies = movies.take(2).toList();
    await render(tester, MovieGrid(movies: selectedMovies));
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.byType(Image), findsNWidgets(2));
    for (final movie in selectedMovies) {
      expect(find.text(movie.title), findsOneWidget);
      expect(
        find.text('★ ${movie.averageRating.toStringAsFixed(1)}'),
        findsOneWidget,
      );
    }
    expect(find.text(movies[2].title), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
