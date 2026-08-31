import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hubx/app/router/app_router.gr.dart';
import 'package:hubx/core/di/dependency_provider.dart';
import 'package:hubx/core/extensions/build_context_x.dart';
import 'package:hubx/core/theme/app_dimensions.dart';
import 'package:hubx/core/theme/app_text_styles.dart';
import 'package:hubx/core/ui/app_skeleton.dart';
import 'package:hubx/features/home/api/home_api.dart';
import 'package:hubx/features/home/ui/bloc/home_bloc.dart';
import 'package:hubx/features/home/ui/paging/categories_paging_controller.dart';
import 'package:hubx/features/home/ui/widgets/category_card.dart';
import 'package:hubx/features/home/ui/widgets/home_search_header.dart';
import 'package:hubx/features/home/ui/widgets/premium_banner.dart';
import 'package:hubx/features/home/ui/widgets/question_cards.dart';
import 'package:hubx/features/paywall/api/paywall_api.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DependencyProvider.get<HomeBloc>()..add(const HomeStarted()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => _HomeScreen(
          state: state,
          onRetryQuestions: () =>
              context.read<HomeBloc>().add(const HomeStarted()),
          onOpenPaywall: () => context.router.pushPath(PaywallRoutes.root),
        ),
      ),
    );
  }
}

/// Pure presentation: no DI, no bloc — takes values, returns callbacks.
///
/// The categories are the exception, and deliberately so: they are a stream of
/// pages rather than a value, and [_Categories] owns the controller that pulls
/// them.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.state,
    required this.onRetryQuestions,
    required this.onOpenPaywall,
  });

  final HomeState state;
  final VoidCallback onRetryQuestions;
  final VoidCallback onOpenPaywall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeSearchHeader(
              topInset: MediaQuery.paddingOf(context).top,
              greetingHeight: HomeSearchHeader.greetingHeightFor(context),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.s24),
            sliver: SliverToBoxAdapter(
              child: PremiumBanner(onTap: onOpenPaywall),
            ),
          ),
          SliverToBoxAdapter(
            child: _Questions(state: state, onRetry: onRetryQuestions),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.s24,
              AppSpacing.s24,
              0,
            ),
            sliver: const _Categories(),
          ),
          // The bar along the bottom is drawn over the body, so the page has
          // to end above it. Without this the last row of the grid — or, when
          // the grid is empty, the button offering to try again — sits under
          // the bar and cannot be tapped at all.
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.s24 + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

class _Questions extends StatelessWidget {
  const _Questions({required this.state, required this.onRetry});

  final HomeState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Text(
            context.l10n.homeGetStarted,
            style: AppTextStyles.medium15.copyWith(
              color: context.palette.textPrimary,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.s12),
        SizedBox(
          height: QuestionCards.height,
          child: switch (state.status) {
            HomeStatus.initial || HomeStatus.loading => AppSkeleton(
              child: QuestionCards(
                questions: _placeholderQuestions,
                withHeroes: false,
                onOpen: (_) {},
              ),
            ),
            HomeStatus.failed => _Failed(onRetry: onRetry),
            HomeStatus.ready => QuestionCards(
              questions: state.questions,
              onOpen: (question) => unawaited(
                context.router.push(
                  ContentDetailRoute(
                    title: question.title,
                    subtitle: question.subtitle,
                    imageUrl: question.imageUrl,
                    heroTag: heroTagFor(question),
                  ),
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}

class _Categories extends StatefulWidget {
  const _Categories();

  @override
  State<_Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  // Resolved from the container rather than built here, so the screen never
  // holds a repository.
  final CategoriesPagingController _controller =
      DependencyProvider.get<CategoriesPagingController>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shared with the loading skeleton, so the bones are the shape of the tiles
  /// that will land on top of them.
  static const _columns = 2;
  static const double _tileAspectRatio = 164 / 152;

  SliverGridDelegate get _grid => SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _columns,
    mainAxisSpacing: AppSpacing.s16,
    crossAxisSpacing: AppSpacing.s16,
    childAspectRatio: _tileAspectRatio,
  );

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _controller,
      builder: (context, state, fetchNextPage) =>
          PagedSliverGrid<int, PlantCategory>(
            state: state,
            fetchNextPage: fetchNextPage,
            gridDelegate: _grid,
            showNewPageErrorIndicatorAsGridChild: false,
            builderDelegate: PagedChildBuilderDelegate<PlantCategory>(
              itemBuilder: (context, category, _) => CategoryCard(
                category: category,
                heroTag: heroTagFor(category),
                onTap: () => unawaited(
                  context.router.push(
                    ContentDetailRoute(
                      title: category.title,
                      imageUrl: category.imageUrl,
                      heroTag: heroTagFor(category),
                    ),
                  ),
                ),
              ),
              // Every way this can go, spelled out: a blank space where a
              // grid should be tells the user nothing about what to do next.
              // A screenful of bones for the first page; a single tile for the
              // next, because the next page is an addition to a grid that is
              // already there and filling the screen again would read as a
              // reload.
              //
              // The new-page indicator is laid into a grid cell, so it is one
              // tile and needs no sizing of its own. The error is a sentence
              // and a button, which will not fit in a cell — that one spans
              // the row instead.
              firstPageProgressIndicatorBuilder: (_) =>
                  const _LoadingTiles(rows: 3),
              newPageProgressIndicatorBuilder: (_) => const _LoadingTile(),
              // Both calls: refresh only clears the failure, and something
              // has to ask for the page again.
              firstPageErrorIndicatorBuilder: (_) => _Failed(
                onRetry: () => _controller
                  ..refresh()
                  ..fetchNextPage(),
              ),
              newPageErrorIndicatorBuilder: (_) =>
                  _Failed(onRetry: _controller.fetchNextPage),
              noItemsFoundIndicatorBuilder: (context) =>
                  _Empty(message: context.l10n.homeCategoriesEmpty),
            ),
          ),
    );
  }
}

/// One tile, drawn empty, for the grid cell the next page will fill.
class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    // No sizing: the grid cell it is laid into is already the shape of a tile.
    return const AppSkeleton(
      child: CategoryCard(category: _placeholderCategory, onTap: _nothing),
    );
  }
}

/// The category grid, drawn empty.
///
/// Laid out by hand rather than with a [GridView]: the package wraps this in a
/// [SliverFillRemaining], which asks its child how tall it wants to be, and a
/// lazy viewport cannot answer that.
class _LoadingTiles extends StatelessWidget {
  const _LoadingTiles({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < rows; row++) ...[
            if (row > 0) SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                for (
                  var column = 0;
                  column < _CategoriesState._columns;
                  column++
                ) ...[
                  if (column > 0) SizedBox(width: AppSpacing.s16),
                  const Expanded(
                    child: AspectRatio(
                      aspectRatio: _CategoriesState._tileAspectRatio,
                      child: CategoryCard(
                        category: _placeholderCategory,
                        onTap: _nothing,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

void _nothing() {}

/// Shapes for the skeletons to lay out. Nothing is read off them: the titles
/// are there to be the length a title is, and the pictures are absent so no
/// request goes out for one.
const _placeholderQuestions = [
  Question(
    id: -1,
    title: 'How to identify plants easily',
    subtitle: '',
    imageUrl: '',
    articleUrl: '',
  ),
  Question(
    id: -2,
    title: 'Differences between species',
    subtitle: '',
    imageUrl: '',
    articleUrl: '',
  ),
];

const _placeholderCategory = PlantCategory(
  id: -1,
  title: 'Edible Plants',
  imageUrl: '',
);

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.homeLoadFailed,
            style: AppTextStyles.regular13.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.s32),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.regular15.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ),
    );
  }
}
