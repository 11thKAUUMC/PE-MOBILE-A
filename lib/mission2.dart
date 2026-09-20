class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

void main() {
  final movies = <Movie>[
    const Movie(id: 1, title: '별빛 아래 우리'),
    const Movie(id: 2, title: '우주의 끝에서'),
    const Movie(id: 3, title: '새로운 영화'),
  ];

  for (final movie in movies) {
    print(movie.title);
  }

  String? nickname;
  final safeNickname = nickname ?? '이름 없음';
  print(safeNickname);
}