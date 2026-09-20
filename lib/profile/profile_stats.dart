import 'package:flutter/material.dart';

import '../widgets/stat_item.dart';
import 'profile_stat.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({
    super.key,
    required this.stats,
  });

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final stat in stats)
          Expanded(
            child: StatItem(
              label: stat.label,
              value: stat.value,
            ),
          ),
      ],
    );
  }
}
