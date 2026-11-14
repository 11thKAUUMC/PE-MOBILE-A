class RatingInput {
  RatingInput({required this.score, String? comment})
    : comment = comment == null || comment.trim().isEmpty ? null : comment {
    if (score < 1 || score > 5) throw RangeError.range(score, 1, 5, 'score');
    if ((this.comment?.runes.length ?? 0) > 500) {
      throw ArgumentError('코멘트는 500자까지 입력할 수 있습니다.');
    }
  }

  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
    'score': score,
    if (comment != null) 'comment': comment,
  };
}

class CreateRatingRequest {
  CreateRatingRequest({required this.movieId, required this.input}) {
    if (movieId < 1) throw ArgumentError.value(movieId, 'movieId');
  }
  final int movieId;
  final RatingInput input;

  Map<String, dynamic> toJson() => {'movieId': movieId, ...input.toJson()};
}
