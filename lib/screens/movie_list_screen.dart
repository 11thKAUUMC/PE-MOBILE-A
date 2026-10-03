import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../theme/app_colors.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String selectedGenre = '전체';

  @override
  Widget build(BuildContext context) {
    const genres = ['전체', '드라마', '미스터리', 'SF', '액션', '로맨스', '스릴러'];

    final filteredMovies = selectedGenre == '전체'
        ? movies
        : movies.where((movie) {
            return movie.genre == selectedGenre;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '영화',
          style: TextStyle(
            color: AppColors.violet,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.violet),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
                itemBuilder: (context, index) {
                  final genre = genres[index];

                  return ChoiceChip(
                    label: Text(genre),
                    selected: selectedGenre == genre,
                    selectedColor: AppColors.violet,
                    backgroundColor: const Color(0xFFE9E5EE),
                    labelStyle: TextStyle(
                      color: selectedGenre == genre
                          ? Colors.white
                          : AppColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: const StadiumBorder(side: BorderSide.none),
                    onSelected: (_) {
                      setState(() {
                        selectedGenre = genre;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: filteredMovies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.54,
                ),
                itemBuilder: (context, index) {
                  return MovieCard(movie: filteredMovies[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
