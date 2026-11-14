import 'package:flutter/material.dart';

import '../data/models/common_response.dart';
import '../data/models/rating_request.dart';
import '../theme/app_colors.dart';
import '../theme/week06_style.dart';
import 'movie_rating_input.dart';
import 'movielog_button.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    required this.onSubmit,
    this.onError,
    this.initialScore = 0,
    this.initialComment,
  });

  final Future<void> Function(RatingInput) onSubmit;
  final ValueChanged<String>? onError;
  final int initialScore;
  final String? initialComment;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;
  late final _comment = TextEditingController(text: widget.initialComment);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || _score < 1) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    FocusScope.of(context).unfocus();
    try {
      await widget.onSubmit(RatingInput(score: _score, comment: _comment.text));
      if (mounted) Navigator.pop(context, _score);
    } catch (error) {
      if (!mounted) return;
      final message = error is MovieLogException
          ? error.message
          : '평점을 저장하지 못했습니다.';
      final onError = widget.onError;
      setState(() {
        _busy = false;
        _error = onError == null ? message : null;
      });
      onError?.call(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialScore > 0;
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 33, 18, 38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editing ? '평점을 수정해주세요' : '평점을 남겨주세요',
                textAlign: TextAlign.center,
                style: Week06Style.text(22, weight: FontWeight.w700),
              ),
              const SizedBox(height: 21),
              Center(
                child: IgnorePointer(
                  ignoring: _busy,
                  child: MovieRatingInput(
                    rating: _score.toDouble(),
                    onChanged: (value) =>
                        setState(() => _score = value.toInt()),
                  ),
                ),
              ),
              const SizedBox(height: 31),
              Text(
                '코멘트 (선택, 최대 500자)',
                style: Week06Style.text(
                  14,
                  color: Week06Style.muted,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comment,
                readOnly: _busy,
                maxLength: 500,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '이 영화의 인상적인 장면은...',
                  filled: true,
                  fillColor: const Color(0xFFF8F5FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Week06Style.outline,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEFE9F8),
                          foregroundColor: AppColors.violet,
                        ),
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.violet,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MovieLogButton(
                      label: '확인',
                      radius: 24,
                      isLoading: _busy,
                      onPressed: _score == 0 || _busy ? null : _save,
                    ),
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
