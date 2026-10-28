import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

Future<bool?> showMovieListRetryDialog({
  required BuildContext context,
  String message = '영화 목록을 불러오지 못했어요.\n다시 시도할까요?',
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('요청 실패'),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('재시도'),
          ),
        ],
      );
    },
  );
}
