import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';

void main() {
  test('v6 실서버에서 신규 학습용 회원의 평점 CRUD를 확인한다', () async {
    final dio = createMovieLogClient();
    addTearDown(dio.close);
    final signUp = SignUpService(dio);
    final ratings = RatingApiService(dio);
    final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final nickname = 'w7$suffix';
    final email = '$nickname@example.com';
    final password = 'Study${DateTime.now().microsecondsSinceEpoch}!';
    final request = CreateMemberRequest(
      nickname: nickname,
      email: email,
      password: password,
    );
    final evidence = <String>[];
    expect(await signUp.checkNickname(nickname), true);
    expect(await signUp.checkEmail(email), true);
    final member = await signUp.signUp(request);
    evidence.add(
      'POST members → 201, memberId=${member.memberId}, nickname=$nickname, email=$email',
    );
    expect(await signUp.checkNickname(nickname), false);
    expect(await signUp.checkEmail(email), false);
    await expectLater(
      signUp.signUp(request),
      throwsA(
        isA<MovieLogException>()
            .having((e) => e.status, 'status', 409)
            .having((e) => e.code, 'code', 'COMMON409'),
      ),
    );
    evidence.add('POST members (동일 계정) → 409 COMMON409');
    final id = member.memberId;
    try {
      expect(await ratings.fetchMyRatings(id), isEmpty);
      await ratings.createRating(
        id,
        CreateRatingRequest(
          movieId: 550,
          input: RatingInput(score: 4, comment: '다시 봐도 좋아요'),
        ),
      );
      final created = (await ratings.fetchMyRatings(id)).single;
      expect(created.movieId, 550);
      expect(created.score, 4);
      expect(created.comment, '다시 봐도 좋아요');
      evidence.add(
        'POST → 201, GET → movieId=550, ratingId=${created.ratingId}, score=4',
      );
      await ratings.updateRating(
        id,
        created.ratingId,
        RatingInput(score: 5, comment: created.comment),
      );
      final updated = (await ratings.fetchMyRatings(id)).single;
      expect(updated.score, 5);
      expect(updated.comment, created.comment);
      evidence.add('PATCH → 200, GET → score=5, comment 유지');
      await ratings.updateRating(id, created.ratingId, RatingInput(score: 5));
      expect((await ratings.fetchMyRatings(id)).single.comment, isNull);
      evidence.add('PATCH (코멘트 비움) → 200, GET → comment=null');
      await ratings.deleteRating(id, created.ratingId);
      expect(await ratings.fetchMyRatings(id), isEmpty);
      evidence.add('DELETE → 204, GET → []');
    } finally {
      for (final row in await ratings.fetchMyRatings(id)) {
        await ratings.deleteRating(id, row.ratingId);
      }
      File('docs/week07/live-v6.txt')
          .writeAsStringSync('${evidence.join('\n')}\n');
    }
  }, skip: !const bool.fromEnvironment('WEEK07_LIVE'));
}
