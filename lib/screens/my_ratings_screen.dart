import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/week06_style.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/tmdb_poster_image.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Week06Style.background,
    appBar: AppBar(
      backgroundColor: Week06Style.background,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      title: Text(
        '내가 등록한 평점',
        style: Week06Style.text(
          20,
          color: AppColors.violet,
          weight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      leading: const BackButton(),
    ),
    body: Consumer<MyRatingsViewModel>(
      builder: (context, vm, _) {
        if (vm.status == MyRatingsLoadStatus.loading ||
            vm.status == MyRatingsLoadStatus.idle) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(19, 31, 19, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (vm.status != MyRatingsLoadStatus.success)
                const Text('학습용 memberId 1의 공개 평점입니다.'),
              if (vm.message != null &&
                  vm.status != MyRatingsLoadStatus.success)
                Text(vm.message!),
              if (vm.status == MyRatingsLoadStatus.error)
                Center(
                  child: MovieLogButton(
                    label: '다시 시도',
                    width: 120,
                    onPressed: vm.load,
                  ),
                ),
              if (vm.status == MyRatingsLoadStatus.empty)
                const Text('아직 등록한 평점이 없습니다.'),
              if (vm.status == MyRatingsLoadStatus.success)
                for (final entry in vm.ratings)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Week06Style.outline, width: 2),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: TmdbPosterImage(
                            posterPath: entry.movie?.posterPath,
                            width: 82,
                            height: 124,
                            placeholder: const ColoredBox(
                              color: Color(0xFFD8D2E0),
                              child: SizedBox(width: 82, height: 124),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.movie?.title ??
                                    '영화 #${entry.rating.movieId}',
                                style: Week06Style.text(
                                  18,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '별점 ${entry.rating.score} / 5',
                                style: Week06Style.text(
                                  14,
                                  color: AppColors.violet,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              if (entry.rating.comment != null ||
                                  entry.movie?.posterPath == null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  entry.rating.comment ?? '포스터 정보 없음',
                                  style: Week06Style.text(
                                    13,
                                    color: Week06Style.muted,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                entry.rating.createdAt
                                    .toLocal()
                                    .toIso8601String()
                                    .substring(0, 10),
                                style: Week06Style.text(
                                  11,
                                  color: Week06Style.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              if (vm.message != null &&
                  vm.status == MyRatingsLoadStatus.success)
                Text(vm.message!),
            ],
          ),
        );
      },
    ),
  );
}
