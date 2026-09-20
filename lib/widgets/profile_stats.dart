import 'package:flutter/material.dart';

import 'stat_item.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatItem(label: '본 영화', value: '24'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatItem(label: '평점', value: '18'),
        ),
        SizedBox(width: 8),
        Expanded(
          child: StatItem(label: '즐겨찾기', value: '7'),
        ),
      ],
    );
  }
}
