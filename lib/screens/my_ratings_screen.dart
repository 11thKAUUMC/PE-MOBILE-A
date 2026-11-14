import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/common_response.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../theme/week06_style.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

const _softViolet = Color(0xFFEFE9F8);
const _softRed = Color(0xFFFDF0EE);
const _red = Color(0xFFB3261E);

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  bool _selecting = false;
  final _selected = <int>{};

  void _notice(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _edit(MyRatingsViewModel vm, RatingWithMovie entry) async {
    final rating = entry.rating;
    final score = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .30),
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment,
        onSubmit: (input) => vm.updateRating(rating.ratingId, input),
      ),
    );
    if (score != null) _notice(vm.refreshWarning ?? '평점을 수정했습니다.');
  }

  Future<void> _delete(MyRatingsViewModel vm, int id) async {
    final confirmed = await _confirmDelete(onDelete: () => vm.deleteRating(id));
    if (confirmed == true) _notice(vm.refreshWarning ?? '평점을 삭제했습니다.');
  }

  Future<void> _deleteSelected(MyRatingsViewModel vm) async {
    final ids = Set<int>.of(_selected);
    if (vm.refreshWarning != null ||
        ids.isEmpty ||
        await _confirmDelete(count: ids.length) != true ||
        !mounted) {
      return;
    }
    final failures = await vm.deleteSelected(ids);
    if (!mounted) return;
    setState(() {
      _selected
        ..clear()
        ..addAll(failures);
      _selecting = failures.isNotEmpty;
    });
    _notice(
      failures.isEmpty
          ? vm.refreshWarning ?? '평점을 삭제했습니다.'
          : '선택한 ${ids.length}개 중 ${failures.length}개를 삭제하지 못했습니다.',
    );
  }

  Future<bool?> _confirmDelete({
    int? count,
    Future<void> Function()? onDelete,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .30),
    builder: (_) => _DeleteDialog(count: count, onDelete: onDelete),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyRatingsViewModel?>();
    final blocked = vm?.isWriting ?? false;
    return PopScope(
      canPop: !blocked,
      child: Stack(
        children: [
          Scaffold(
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
              leading: BackButton(
                onPressed: blocked
                    ? () {}
                    : () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/my');
                        }
                      },
              ),
            ),
            body: vm == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('회원가입 후 평점을 조회할 수 있습니다.'),
                        const SizedBox(height: 12),
                        MovieLogButton(
                          label: '회원가입',
                          onPressed: () => context.push('/signup'),
                        ),
                      ],
                    ),
                  )
                : _body(vm),
            bottomNavigationBar: vm == null || !_selecting
                ? null
                : SafeArea(
                    minimum: const EdgeInsets.fromLTRB(24, 8, 24, 74),
                    child: MovieLogButton(
                      label: '선택한 ${_selected.length}개 삭제',
                      radius: 25,
                      width: double.infinity,
                      onPressed:
                          _selected.isEmpty ||
                              blocked ||
                              vm.refreshWarning != null
                          ? null
                          : () => _deleteSelected(vm),
                    ),
                  ),
          ),
          if (vm?.isDeletingSelected ?? false)
            const Positioned.fill(
              child: Stack(
                children: [
                  ModalBarrier(dismissible: false, color: Color(0x66000000)),
                  Center(
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(MyRatingsViewModel vm) {
    if ((vm.status == MyRatingsLoadStatus.loading ||
            vm.status == MyRatingsLoadStatus.idle) &&
        !vm.isDeletingSelected) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(19, 15, 19, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (vm.status == MyRatingsLoadStatus.error &&
              !vm.isDeletingSelected) ...[
            Text(vm.refreshWarning ?? vm.message ?? '평점을 불러오지 못했습니다.'),
            const SizedBox(height: 12),
            Center(
              child: MovieLogButton(
                label: '다시 시도',
                width: 120,
                onPressed: vm.isWriting ? null : vm.load,
              ),
            ),
          ],
          if (vm.status == MyRatingsLoadStatus.empty)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Center(child: Text('아직 등록한 평점이 없습니다.')),
            ),
          if (vm.ratings.isNotEmpty &&
              (vm.status == MyRatingsLoadStatus.success ||
                  vm.isDeletingSelected ||
                  vm.refreshWarning != null)) ...[
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 12, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selecting ? '${_selected.length}개 선택됨' : '',
                      style: Week06Style.text(
                        14,
                        color: AppColors.violet,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: vm.isWriting
                        ? null
                        : () => setState(() {
                            _selecting = !_selecting;
                            _selected.clear();
                          }),
                    child: Text(
                      _selecting ? '취소' : '편집',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            for (final entry in vm.ratings) _card(vm, entry),
          ],
        ],
      ),
    );
  }

  Widget _card(MyRatingsViewModel vm, RatingWithMovie entry) {
    final rating = entry.rating;
    final title = entry.movie?.title ?? '영화 #${rating.movieId}';
    return Container(
      constraints: BoxConstraints(minHeight: _selecting ? 130 : 158),
      margin: EdgeInsets.only(bottom: _selecting ? 13 : 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Week06Style.outline, width: 2),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          if (_selecting) ...[
            SizedBox(
              width: 26,
              child: Checkbox(
                value: _selected.contains(rating.ratingId),
                onChanged: vm.isWriting
                    ? null
                    : (checked) => setState(() {
                        if (checked == true) {
                          _selected.add(rating.ratingId);
                        } else {
                          _selected.remove(rating.ratingId);
                        }
                      }),
              ),
            ),
            const SizedBox(width: 21),
          ] else ...[
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
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selecting ? '$title · 별점 ${rating.score}' : title,
                  style: Week06Style.text(18, weight: FontWeight.w700),
                ),
                if (!_selecting) ...[
                  const SizedBox(height: 12),
                  Text(
                    '별점 ${rating.score} / 5',
                    style: Week06Style.text(
                      14,
                      color: AppColors.violet,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
                if (rating.comment != null ||
                    (!_selecting && entry.movie?.posterPath == null)) ...[
                  const SizedBox(height: 12),
                  Text(
                    rating.comment ?? '포스터 정보 없음',
                    style: Week06Style.text(13, color: Week06Style.muted),
                  ),
                ],
              ],
            ),
          ),
          if (!_selecting) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _softButton(
                  context,
                  '수정',
                  vm.isWriting || vm.refreshWarning != null
                      ? null
                      : () => _edit(vm, entry),
                  width: 63,
                  height: 35,
                ),
                const SizedBox(height: 8),
                _softButton(
                  context,
                  '삭제',
                  vm.isWriting || vm.refreshWarning != null
                      ? null
                      : () => _delete(vm, rating.ratingId),
                  width: 63,
                  height: 35,
                  danger: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Widget _softButton(
  BuildContext context,
  String label,
  VoidCallback? action, {
  double? width,
  double height = 44,
  bool danger = false,
}) => SizedBox(
  width: width,
  height: height,
  child: TextButton(
    style: TextButton.styleFrom(
      foregroundColor: danger ? _red : AppColors.violet,
      backgroundColor: danger ? _softRed : _softViolet,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    onPressed: action,
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: action == null
            ? Week06Style.muted
            : danger
            ? _red
            : AppColors.violet,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
);

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.count, required this.onDelete});
  final int? count;
  final Future<void> Function()? onDelete;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy) return;
    final delete = widget.onDelete;
    if (delete == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await delete();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error is MovieLogException ? error.message : '평점을 삭제하지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 31),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 37, 18, 37),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.count == null
                  ? '평점을 삭제할까요?'
                  : '평점 ${widget.count}개를 삭제할까요?',
              textAlign: TextAlign.center,
              style: Week06Style.text(21, weight: FontWeight.w700),
            ),
            const SizedBox(height: 19),
            Text(
              '삭제한 평점은 복구할 수 없습니다.',
              textAlign: TextAlign.center,
              style: Week06Style.text(14, color: Week06Style.muted),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: _red)),
            const SizedBox(height: 55),
            Row(
              children: [
                Expanded(
                  child: _softButton(
                    context,
                    '취소',
                    _busy ? null : () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: MovieLogButton(
                    label: '삭제',
                    radius: 9,
                    isLoading: _busy,
                    onPressed: _busy ? null : _submit,
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
