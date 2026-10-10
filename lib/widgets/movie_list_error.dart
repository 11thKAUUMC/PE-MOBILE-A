import 'package:flutter/material.dart';

class MovieListError extends StatelessWidget {
  const MovieListError({
    super.key,
    required this.onRetry,
    this.isTimeout = false,
  });

  final VoidCallback onRetry;
  final bool isTimeout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(isTimeout ? '응답 시간이 초과되었습니다.' : '영화를 불러오지 못했습니다.'),
          const SizedBox(height: 8),
          Text(isTimeout ? '응답이 늦어지고 있어요. 다시 시도해 주세요.' : '잠시 후 다시 시도해 주세요.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
