import 'package:flutter/material.dart';

class Movie {
  const Movie({required this.id, required this.title});
  final int id;
  final String title;
}

final List<Movie> movies = [
  const Movie(id: 1, title: 'Movie 1'),
  const Movie(id: 2, title: 'Movie 2'),
  const Movie(id: 3, title: 'Movie 3'),
];

String? nickname;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Flutter 시작!'),
              Text('닉네임: ${nickname ?? '게스트'}'),
            ] + movies.map((movie) => Text(movie.title)).toList(),
          ),
        ),
      ),
    ),
  );
}