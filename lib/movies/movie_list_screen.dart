import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_movies.dart';
import '../router/app_router.dart';
import '../widgets/common_app_bar.dart';
import 'genre_filter_sheet.dart';
import 'movie_grid.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key, required this.selectedGenres});

  final Set<String> selectedGenres;

  Future<void> _openFilter(BuildContext context) async {
    final genres = await GenreFilterSheet.show(
      context,
      genres: movieGenres,
      selected: selectedGenres,
    );
    if (genres == null || !context.mounted) return;

    context.go(AppRouter.moviesLocation(genres));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            genres.isEmpty
                ? '전체 영화를 보여드릴게요.'
                : '${genres.join(', ')} 장르를 적용했습니다.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenres.isEmpty
        ? movies
        : movies
              .where((movie) => selectedGenres.contains(movie.genre))
              .toList();

    return Scaffold(
      appBar: CommonAppBar(
        title: '영화',
        actions: [
          IconButton(
            onPressed: () => _openFilter(context),
            tooltip: '장르 필터',
            icon: Badge(
              isLabelVisible: selectedGenres.isNotEmpty,
              label: Text('${selectedGenres.length}'),
              child: const Icon(Icons.filter_list),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: MovieGrid(movies: filteredMovies),
    );
  }
}
