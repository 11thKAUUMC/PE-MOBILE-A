import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/movie_list_view_model.dart';
import '../widgets/common_app_bar.dart';
import 'genre_chips.dart';
import 'genre_filter_sheet.dart';
import 'movie_grid.dart';
import 'movie_list_empty.dart';
import 'movie_list_error.dart';
import 'movie_list_loading.dart';
import 'movie_list_retry_dialog.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  MovieListViewModel? _viewModel;
  var _dialogVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<MovieListViewModel>();
    if (!identical(_viewModel, viewModel)) {
      _viewModel?.removeListener(_onViewModelChanged);
      _viewModel = viewModel;
      _viewModel?.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    final viewModel = _viewModel;
    if (viewModel == null || !viewModel.showRetryDialog || _dialogVisible) {
      return;
    }
    _showRetryDialog(viewModel);
  }

  Future<void> _showRetryDialog(MovieListViewModel viewModel) async {
    _dialogVisible = true;
    final shouldRetry = await showMovieListRetryDialog(
      context: context,
      message:
          viewModel.message ?? '영화 목록을 불러오지 못했어요.\n최근 목록은 유지됩니다.',
    );
    _dialogVisible = false;
    if (!mounted) return;

    final current = context.read<MovieListViewModel>();
    if (shouldRetry == true) {
      await current.retryLastRequest();
    } else {
      current.dismissRetryDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CommonAppBar(
            title: '영화',
            actions: [
              IconButton(
                tooltip: '장르 다중 선택',
                onPressed: !viewModel.canChangeGenre
                    ? null
                    : () => _openGenreSheet(viewModel),
                icon: const Icon(Icons.filter_list),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (viewModel.genres.isNotEmpty)
                GenreChips(
                  genres: viewModel.genres,
                  selectedGenreIds: viewModel.selectedGenreIds,
                  enabled: viewModel.canChangeGenre,
                  onSelected: (genreId) {
                    context.read<MovieListViewModel>().selectGenre(genreId);
                  },
                ),
              Expanded(child: _buildBody(viewModel)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(MovieListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.movies.isEmpty) {
      return const MovieListLoading();
    }

    if (viewModel.status == MovieListLoadStatus.error &&
        viewModel.movies.isEmpty) {
      return MovieListError(
        message: viewModel.message ?? MovieListError.defaultMessage,
        onRetry: () => context.read<MovieListViewModel>().retryLastRequest(),
      );
    }

    if (viewModel.status == MovieListLoadStatus.empty &&
        viewModel.movies.isEmpty) {
      return const MovieListEmpty();
    }

    final grid = MovieGrid(movies: viewModel.movies);

    if (viewModel.isLoading) {
      return Stack(
        children: [
          grid,
          const ColoredBox(
            color: Color(0x66FFFFFF),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MovieListViewModel>().refresh(),
      notificationPredicate: (notification) =>
          !viewModel.isLoading &&
          !viewModel.isRefreshing &&
          notification.depth == 0,
      child: grid,
    );
  }

  Future<void> _openGenreSheet(MovieListViewModel viewModel) async {
    final selected = await showGenreFilterSheet(
      context: context,
      genres: viewModel.genres,
      initiallySelected: viewModel.selectedGenreIds,
    );
    if (!mounted || selected == null) return;
    await context.read<MovieListViewModel>().selectGenres(selected);
  }
}
