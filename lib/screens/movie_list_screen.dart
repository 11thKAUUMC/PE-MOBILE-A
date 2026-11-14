import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_list_view_model.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_loading.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  int _shownError = 0;
  bool _dialogOpen = false;
  String _search = '';
  bool _searchOpen = false;

  Widget _genreChip(String name, bool selected, VoidCallback? onTap) =>
      ChoiceChip(
        label: Text(name),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.black,
          fontSize: 12,
        ),
        selectedColor: AppColors.violet,
        backgroundColor: const Color(0xFFF0EDF4),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        onSelected: onTap == null ? null : (_) => onTap(),
      );
  void _scheduleError(MovieListViewModel vm) {
    if (vm.errorVersion <= _shownError || _dialogOpen) return;
    _shownError = vm.errorVersion;
    if (vm.movies.isEmpty) return;
    _dialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.genreChip,
                    foregroundColor: AppColors.violet,
                    radius: 25,
                    child: Icon(Icons.restart_alt),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '영화를 불러오지 못했어요',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '네트워크 상태를 확인하고\n다시 시도해 주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF3EEFA),
                            foregroundColor: AppColors.violet,
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('다시 시도'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      _dialogOpen = false;
      if (mounted && retry == true) await vm.retry();
    });
  }

  Future<void> _selectGenres(MovieListViewModel vm) async {
    final draft = vm.selectedGenreIds.toSet();
    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.warmWhite,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .45,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '장르 필터',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '여러 장르를 선택할 수 있어요',
                    style: TextStyle(color: AppColors.gray),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final genre in vm.genres)
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(genre.name),
                            value: draft.contains(genre.id),
                            onChanged: (selected) => setSheetState(() {
                              if (selected == true) {
                                draft.add(genre.id);
                              } else {
                                draft.remove(genre.id);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, draft.toList()),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    await vm.selectGenres(result);
  }

  @override
  Widget build(BuildContext context) => Consumer<MovieListViewModel>(
    builder: (context, vm, child) {
      _scheduleError(vm);
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: _searchOpen
              ? TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _search = value.trim()),
                  decoration: const InputDecoration(
                    hintText: '현재 목록에서 영화 찾기',
                    border: InputBorder.none,
                  ),
                )
              : const Text(
                  '영화',
                  style: TextStyle(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          actions: [
            IconButton(
              tooltip: _searchOpen ? '검색 닫기' : '검색',
              onPressed: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) _search = '';
              }),
              icon: Icon(
                _searchOpen ? Icons.close : Icons.search,
                color: AppColors.violet,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: '장르 다중 선택',
                  onPressed: vm.busy || vm.genres.isEmpty
                      ? null
                      : () => _selectGenres(vm),
                  icon: const Icon(Icons.filter_list, color: AppColors.violet),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _genreChip(
                        '전체',
                        vm.selectedGenreIds.isEmpty,
                        vm.busy ? null : () => vm.selectGenres(const []),
                      ),
                    ),
                    for (final genre in vm.genres)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _genreChip(
                          genre.name,
                          vm.selectedGenreIds.contains(genre.id),
                          vm.busy ? null : () => vm.selectGenres([genre.id]),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '영화 ${vm.movies.length}개 · 최대 30개',
                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '새로고침',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    onPressed: vm.busy ? null : vm.refresh,
                    icon: const Icon(Icons.refresh, color: AppColors.violet),
                  ),
                ],
              ),
              if (vm.refreshing) const LinearProgressIndicator(),
              Expanded(
                child: switch (vm.status) {
                  MovieLoadStatus.idle ||
                  MovieLoadStatus.loading => const MovieListLoading(),
                  MovieLoadStatus.error => MovieListError(onRetry: vm.retry),
                  MovieLoadStatus.empty ||
                  MovieLoadStatus.success => RefreshIndicator(
                    onRefresh: vm.refresh,
                    notificationPredicate: (_) => !vm.busy,
                    child:
                        !vm.movies.any(
                          (m) => m.title.toLowerCase().contains(
                            _search.toLowerCase(),
                          ),
                        )
                        ? const MovieListEmpty()
                        : MovieGrid(
                            tmdbById: {
                              for (final movie in vm.movies) movie.id: movie,
                            },
                            movies: vm.movies
                                .where(
                                  (m) => m.title.toLowerCase().contains(
                                    _search.toLowerCase(),
                                  ),
                                )
                                .map((m) => m.toMovie(vm.genres))
                                .toList(),
                          ),
                  ),
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
