import 'package:flutter/material.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 48),
          SizedBox(height: 16),
          Text('조건에 맞는 영화가 없습니다.'),
        ],
      ),
    );
  }
}
