import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../widgets/common_app_bar.dart';
import 'genre_chips.dart';
import 'movie_grid.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String? _selectedGenre;

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _selectedGenre == null
        ? movies
        : movies.where((movie) => movie.genre == _selectedGenre).toList();

    return Scaffold(
      appBar: CommonAppBar(
        title: '영화',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: '검색',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          GenreChips(
            genres: movieGenres,
            selectedGenre: _selectedGenre,
            onSelected: (genre) => setState(() => _selectedGenre = genre),
          ),
          const SizedBox(height: 16),
          Expanded(child: MovieGrid(movies: filteredMovies)),
        ],
      ),
    );
  }
}
