import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../data/mock_movies.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double? myRating;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);

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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? '즐겨찾기에 추가했습니다.'
                        : '즐겨찾기에서 삭제했습니다.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
            ),
            tooltip: isFavorite ? '즐겨찾기 삭제' : '즐겨찾기 추가',
          ),
        ],
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

            // 평균 평점 표시
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

            const SizedBox(height: 24),

            // 이 위치에 평점 남기기 버튼 추가
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final rating = await showDialog<double>(
                  context: context,
                  builder: (_) => const RatingDialog(),
                );

                if (!mounted || rating == null) return;

                setState(() {
                  myRating = rating;
                });
              },
              child: const Text('평점 남기기'),
            ),

            if (myRating != null) ...[
              const SizedBox(height: 12),
              Text(
                '내 평점: ${myRating!.toStringAsFixed(1)}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}