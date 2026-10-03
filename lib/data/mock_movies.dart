import '../models/movie.dart';

const List<Movie> movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    duration: 124,
    averageRating: 4.5,
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만납니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시 깨닫게 되는 따뜻한 이야기입니다.',
    tags: ['로맨스', '드라마', '감동적인'],
  ),
  Movie(
    id: 2,
    title: '속삭이는 숲',
    genre: '미스터리',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    duration: 108,
    averageRating: 4.9,
    synopsis: '고요한 숲에서 들려오는 낯선 목소리를 따라간 한 아이가 오래된 비밀과 마주하는 판타지 미스터리입니다.',
    tags: ['미스터리', '판타지', '힐링'],
  ),
  Movie(
    id: 3,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    duration: 118,
    averageRating: 4.2,
    synopsis: '우주의 끝을 탐사하던 승무원들이 설명할 수 없는 신호를 발견하며 벌어지는 SF 서스펜스입니다.',
    tags: ['SF', '우주', '서스펜스'],
  ),
  Movie(
    id: 4,
    title: '심연의 방랑자',
    genre: '액션',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    duration: 115,
    averageRating: 4.1,
    synopsis: '심연을 탐험하는 방랑자가 사라진 동료를 찾기 위해 위험한 세계로 떠나는 액션 어드벤처입니다.',
    tags: ['액션', '모험', '판타지'],
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    duration: 102,
    averageRating: 4.3,
    synopsis: '매달 네 번째 오후에만 만나는 두 사람이 서로의 일상에 작은 변화를 만들어 가는 로맨스입니다.',
    tags: ['로맨스', '일상', '감성'],
  ),
  Movie(
    id: 6,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    duration: 110,
    averageRating: 3.8,
    synopsis: '비 내리는 도시의 골목에서 시작된 실종 사건을 추적하는 한 형사의 어두운 스릴러입니다.',
    tags: ['스릴러', '미스터리', '범죄'],
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) {
      return movie;
    }
  }

  return null;
}
