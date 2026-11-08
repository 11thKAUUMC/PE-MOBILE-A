import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/week06_style.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isProfile = currentIndex == 2;
    final navigation = NavigationBar(
      height: isProfile ? 64 : null,
      backgroundColor: isProfile ? Colors.white : null,
      indicatorColor: isProfile ? const Color(0xFFEEE1FA) : null,
      labelTextStyle: isProfile
          ? WidgetStateProperty.resolveWith(
              (states) => Week06Style.text(
                12,
                color: states.contains(WidgetState.selected)
                    ? AppColors.violet
                    : Week06Style.muted,
                weight: FontWeight.w700,
              ),
            )
          : null,
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/movies');
          case 2:
            context.go('/my');
        }
      },
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: isProfile ? Week06Style.muted : null,
          ),
          selectedIcon: Icon(Icons.home),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(
            isProfile ? Icons.calendar_today_outlined : Icons.movie_outlined,
            color: isProfile ? Week06Style.muted : null,
          ),
          selectedIcon: Icon(Icons.movie),
          label: '영화',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(
            Icons.person,
            color: isProfile ? AppColors.violet : null,
          ),
          label: '마이',
        ),
      ],
    );
    return Scaffold(
      body: child,
      bottomNavigationBar: isProfile
          ? ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: navigation,
              ),
            )
          : navigation,
    );
  }
}
