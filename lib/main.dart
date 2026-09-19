import 'package:flutter/material.dart';

class Movie {
  const Movie({required this.id, required this.title});
  final int id;
  final String title;
}

void main() {
  List<Movie> movies = [
    Movie(id: 1, title: '스파이더맨'),
    Movie(id: 2, title: '나우유씨미'),
    Movie(id: 3, title: '오디세이'),
  ];

  String? nickname;
  String name = nickname ?? "비회원";
  String text = '$name님의 시청 목록\n';

  for (Movie movie in movies) {
    text += '${movie.id}:${movie.title}\n';
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text(text))),
    ),
  );
}
