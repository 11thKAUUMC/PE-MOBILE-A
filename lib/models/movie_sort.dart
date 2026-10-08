import 'movie.dart';

enum MovieSort {
  basic('기본순'),
  latest('최신순'),
  rating('평점순'),
  title('제목순');

  const MovieSort(this.label);

  final String label;

  static MovieSort fromName(String? name) {
    for (final sort in values) {
      if (sort.name == name) return sort;
    }
    return basic;
  }

  List<Movie> apply(List<Movie> movies) {
    final sorted = [...movies];
    switch (this) {
      case MovieSort.basic:
        sorted.sort((a, b) => a.id.compareTo(b.id));
      case MovieSort.latest:
        sorted.sort((a, b) {
          final byYear = b.year.compareTo(a.year);
          return byYear != 0 ? byYear : a.id.compareTo(b.id);
        });
      case MovieSort.rating:
        sorted.sort((a, b) {
          final byRating = b.rating.compareTo(a.rating);
          return byRating != 0 ? byRating : a.id.compareTo(b.id);
        });
      case MovieSort.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
    }
    return sorted;
  }
}
