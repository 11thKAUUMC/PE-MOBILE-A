import 'package:movielog/models/movie.dart';

// 상태 구분 enum
enum MovieLoadMode { success, empty, failure }

// Exception 처리
class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

// 가짜 서비스 class
class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 가짜 지연
    // TODO(5주차 유저별 평점 조회 API): Mock 처리를 실제 API 호출로 교체
    await Future<void>.delayed(const Duration(seconds: 1));

    // mode 조건 분기
    return switch (mode) {
      MovieLoadMode.success => mockMovies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.8,
    ratingCount: 1245,
    runtime: '124분',
    description: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아 가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    ratingCount: 1045,
    runtime: '100분',
    description: '미지의 우주 공간을 탐사하던 중 마주한 경이로운 선택의 순간과 거대한 비밀.',
  ),
  Movie(
    id: 3,
    title: '속삭이는 숲',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    ratingCount: 1445,
    runtime: '120분',
    description: '오래된 숲속에서 들려오는 비밀스러운 이야기와 감동적인 만남.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    ratingCount: 9005,
    runtime: '60분',
    description: '어두운 도심 속 뒤얽힌 진실과 숨막히는 추격전.',
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
    ratingCount: 1045,
    runtime: '70분',
    description: '지친 일상에 찾아온 찬란하고 잔잔한 휴식 같은 이야기.',
  ),
  Movie(
    id: 6,
    title: '스파이 코드',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.8,
    ratingCount: 1340,
    runtime: '180분',
    description: '깊은 심연 속에서 밝혀지는 인류의 새로운 가능성.',
  ),
];

Movie? findMovieById(int? id) {
  if (id == null) return null;
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}
