import 'package:flutter/material.dart';
import 'package:movielog/widgets/tmdb_movie_card.dart';
import 'package:provider/provider.dart';

import '../services/genre_preference.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_list_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movie_state.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final genrePreference = GenrePreference();

  bool _isRestoringGenre = true;
  bool _isSavingGenre = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreGenre();
    });
  }

  Future<void> _restoreGenre() async {
    try {
      final savedGenre = await genrePreference.read();

      if (!mounted) return;

      final viewModel = context.read<MovieListViewModel>();

      // Route에서 시작한 초기 로딩이 끝날 때까지 기다린다.
      // 기다리는 동안 화면이 닫히면 종료한다.
      while (viewModel.status == MovieListLoadStatus.idle ||
          viewModel.status == MovieListLoadStatus.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 50));

        if (!mounted) return;
      }

      if (viewModel.status == MovieListLoadStatus.error) return;

      int? savedGenreId;

      for (final genre in viewModel.genres) {
        if (genre.name == savedGenre) {
          savedGenreId = genre.id;
          break;
        }
      }

      if (viewModel.selectedGenreId != savedGenreId) {
        await viewModel.selectGenre(savedGenreId);
      }
    } catch (error) {
      debugPrint('장르 복원 실패: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isRestoringGenre = false;
        });
      }
    }
  }

  Future<void> _selectGenre(int? genreId, String genreName) async {
    final viewModel = context.read<MovieListViewModel>();

    if (_isRestoringGenre ||
        _isSavingGenre ||
        viewModel.status == MovieListLoadStatus.loading) {
      return;
    }

    setState(() {
      _isSavingGenre = true;
    });

    // await 전에 호출하므로 즉시 loading 상태로 바뀐다.
    final request = viewModel.selectGenre(genreId);

    try {
      await genrePreference.save(genreName);
    } catch (error) {
      debugPrint('장르 저장 실패: $error');

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('장르 선택을 저장하지 못했습니다.')));
      }
    } finally {
      try {
        await request;
      } finally {
        if (mounted) {
          setState(() {
            _isSavingGenre = false;
          });
        }
      }
    }
  }

  void _retry() {
    final viewModel = context.read<MovieListViewModel>();

    if (viewModel.genres.isEmpty) {
      viewModel.loadInitial();
    } else {
      viewModel.selectGenre(viewModel.selectedGenreId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieListViewModel>();

    final isBusy =
        _isRestoringGenre ||
        _isSavingGenre ||
        viewModel.status == MovieListLoadStatus.loading;

    final genreNames = {
      for (final genre in viewModel.genres) genre.id: genre.name,
    };

    return Scaffold(
      appBar: const CommonAppBar(title: '영화'),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.genres.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = index == 0 ? null : viewModel.genres[index - 1];

                final int? genreId = genre?.id;
                final genreName = genre?.name ?? '전체';

                final isSelected = genreId == viewModel.selectedGenreId;

                return ChoiceChip(
                  label: Text(genreName),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.violet,
                  disabledColor: isSelected
                      ? AppColors.violet
                      : AppColors.darkWhite,
                  backgroundColor: AppColors.darkWhite,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: const StadiumBorder(side: BorderSide.none),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: isBusy
                      ? null
                      : (selected) {
                          if (selected && !isSelected) {
                            _selectGenre(genreId, genreName);
                          }
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildMovieList(viewModel, genreNames)),
        ],
      ),
    );
  }

  Widget _buildMovieList(
    MovieListViewModel viewModel,
    Map<int, String> genreNames,
  ) {
    if (_isRestoringGenre ||
        viewModel.status == MovieListLoadStatus.idle ||
        viewModel.status == MovieListLoadStatus.loading) {
      return const MovieListLoading();
    }

    if (viewModel.status == MovieListLoadStatus.error) {
      return MovieListError(onRetry: _retry);
    }

    if (viewModel.status == MovieListLoadStatus.empty ||
        viewModel.movies.isEmpty) {
      return const MovieListEmpty();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: viewModel.movies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return TmdbMovieCard(
            movie: viewModel.movies[index],
            genreNames: genreNames,
          );
        },
      ),
    );
  }
}
