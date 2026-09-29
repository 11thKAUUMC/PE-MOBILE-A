import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/mock_movies.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  final int? movieId;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(movieId);

    if (movie == null) {
      return const Scaffold(
        body: Center(
          child: Text('영화를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              movie.posterAsset,
              width: double.infinity,
              height: 360,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 24),
            Text(
              movie.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${movie.genre} · ${movie.year}'),
            const SizedBox(height: 16),
            Row(
              children: [
                RatingBarIndicator(
                  rating: 4.5,
                  itemCount: 5,
                  itemSize: 24,
                  itemBuilder: (context, index) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text('4.5'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}