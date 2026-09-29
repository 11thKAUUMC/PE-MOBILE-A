import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 180,
          height: 280,
          child: MovieCard(movie: movies.first),
        ),
      ),
    );
  }
}