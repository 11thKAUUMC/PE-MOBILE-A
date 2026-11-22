import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('내 프로필'),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthViewModel>().logout(),
            child: const Text('로그아웃'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage(
                        'assets/images/profile_movielog.jpg',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      member?.nickname ?? '사용자',
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(member?.email ?? ''),

                    if (auth.memberStatus == MemberLoadStatus.loading)
                      const Center(child: CircularProgressIndicator()),

                    if (auth.memberStatus == MemberLoadStatus.failure)
                      TextButton(
                        onPressed: auth.loadMember,
                        child: const Text('내 정보 다시 불러오기'),
                      ),

                    const SizedBox(height: 8),

                    const Text(
                      '매주 주말엔 영화관으로 출근하는 프로 관람객, '
                      '좋은 영화를 보고 기록하는 것을 좋아합니다.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: member == null
                      ? null
                      : () => context.push('/my/profile/edit'),

                  style: TextButton.styleFrom(
                    fixedSize: const Size(127, 42),
                    foregroundColor: AppColors.violet,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),

                    side: const BorderSide(width: 1, color: AppColors.violet),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: Text(
                    '프로필 수정',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.violet,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Expanded(
                    child: StatItem(
                      label: '본 영화',
                      value: '342',
                      margin: EdgeInsets.only(right: 4),
                    ),
                  ),

                  Expanded(
                    child: StatItem(
                      label: '평점',
                      value: '4.2',
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),

                  Expanded(
                    child: StatItem(
                      label: '즐겨찾기',
                      value: '58',
                      margin: EdgeInsets.only(left: 4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightViolet),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: const Text(
                    '내가 등록한 평점',
                    style: AppTextStyles.bodyMedium,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.violet,
                  ),
                  onTap: () => context.push('/my/ratings'),
                ),
              ),

              const SizedBox(height: 20),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text('선호하는 장르', style: AppTextStyles.bodyMedium),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Chip(
                        label: Text(
                          '드라마',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.violet,
                          ),
                        ),
                        backgroundColor: AppColors.lightViolet,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Chip(
                        label: Text(
                          'SF',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.violet,
                          ),
                        ),
                        backgroundColor: AppColors.lightViolet,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Chip(
                        label: Text(
                          '애니메이션',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.violet,
                          ),
                        ),
                        backgroundColor: AppColors.lightViolet,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.margin = EdgeInsets.zero,
  });

  final String label;
  final String value;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.lightViolet, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),

          const SizedBox(height: 4),

          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.violet),
          ),
        ],
      ),
    );
  }
}
