enum MovieSort {
  original('기본 순서'),
  rating('평점 높은 순'),
  newest('최신 개봉 순');

  const MovieSort(this.label);

  final String label;
}
