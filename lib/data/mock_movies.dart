import '../models/movie.dart';

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    ratingCount: 1245,
    runtimeMinutes: 124,
    tags: ['로맨스', '드라마', '감동적인'],
    synopsis:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 '
        '만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 '
        '깨닫게 되는 따뜻한 이야기입니다.\n\n'
        '과거의 아픔으로 인해 타인에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 '
        '자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 '
        '현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n'
        '별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 '
        '영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    ratingCount: 982,
    runtimeMinutes: 138,
    tags: ['SF', '우주', '미스터리'],
    synopsis:
        '인류의 마지막 탐사선이 우주의 끝에서 정체불명의 신호를 수신합니다. 홀로 남은 탐사대원은 '
        '신호의 근원을 찾아 황량한 행성에 발을 딛고, 그곳에서 인류의 기원과 맞닿은 진실을 마주하게 됩니다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    ratingCount: 2310,
    runtimeMinutes: 102,
    tags: ['애니메이션', '판타지', '가족'],
    synopsis:
        '속삭이는 숲에 들어선 소녀는 잃어버린 기억을 간직한 작은 정령을 만납니다. 둘은 숲의 '
        '비밀을 풀기 위해 함께 모험을 떠나고, 그 과정에서 진정한 우정의 의미를 배워갑니다.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    ratingCount: 754,
    runtimeMinutes: 116,
    tags: ['스릴러', '범죄', '느와르'],
    synopsis:
        '비 내리는 도시의 뒷골목, 연쇄 실종 사건을 쫓던 형사는 매번 현장에 남겨진 그림자의 '
        '흔적을 발견합니다. 진실에 가까워질수록 그 그림자는 형사 자신을 향해 다가옵니다.',
  ),
  Movie(
    id: 5,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.3,
    ratingCount: 1108,
    runtimeMinutes: 109,
    tags: ['로맨스', '일상', '힐링'],
    synopsis:
        '매주 같은 시간, 같은 카페에서 마주치는 두 사람. 네 번째 오후, 용기를 낸 한마디로 '
        '시작된 대화는 서로의 평범한 하루를 조금씩 특별하게 바꾸어 갑니다.',
  ),
  Movie(
    id: 6,
    title: '미션 임프로버블',
    genre: '코미디',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.0,
    ratingCount: 1532,
    runtimeMinutes: 112,
    tags: ['코미디', '액션', '첩보'],
    synopsis:
        '전설의 첩보원 맥스 스틸러가 돌아왔습니다. 이번 임무는 세계를 구하는 것보다 더 어려운, '
        '은퇴 파티를 무사히 마치는 것. 폭발보다 큰 웃음이 터지는 액션 코미디.',
  ),
];

final movieGenres = movies.map((movie) => movie.genre).toSet().toList();

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
