import 'package:flutter/material.dart';

import '../widgets/common_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CommonAppBar(title: 'MovieLog'),
      body: SafeArea(child: Center(child: Text('오늘은 어떤 영화를 볼까요?'))),
    );
  }
}
