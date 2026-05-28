import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'paginated_list_cubit.dart';
import 'paginated_list_state.dart';

/// Shared cursor-paginated list shell. Subclasses fill in item/empty/error UI.
abstract class PaginatedListView<T, C extends PaginatedListCubit<T>>
    extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.cubit,
    this.reverse = false,
    this.padding,
    this.scrollController,
    this.autoLoadOnMount = true,
  });

  final C cubit;

  final bool reverse;

  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  final bool autoLoadOnMount;

  Widget listItemBuilder(T item, BuildContext context, int index);

  Widget noItemFoundBuilder(BuildContext context);

  Widget listingErrorWidget(PaginatedListState<T> state);

  void onListingError(PaginatedListState<T> state);

  Widget initialStateWidget(BuildContext context) => loadingWidget();

  Widget listingStateWidget(BuildContext context) => loadingWidget();

  Widget loadingWidget() => const Center(child: CircularProgressIndicator());

  @override
  State<PaginatedListView<T, C>> createState() =>
      _PaginatedListViewState<T, C>();
}

class _PaginatedListViewState<T, C extends PaginatedListCubit<T>>
    extends State<PaginatedListView<T, C>> {
  @override
  void initState() {
    super.initState();
    if (!widget.autoLoadOnMount) return;
    final state = widget.cubit.state;
    if (state is PaginatedListInitial<T> ||
        (state is PaginatedListError<T> && state.items.isEmpty)) {
      widget.cubit.loadInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, PaginatedListState<T>>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is PaginatedListInitial<T>) {
          return widget.initialStateWidget(context);
        }
        if (state is PaginatedListLoading<T> &&
            state.isInitial &&
            state.items.isEmpty) {
          return widget.listingStateWidget(context);
        }
        if (state is PaginatedListError<T> && state.items.isEmpty) {
          widget.onListingError(state);
          return widget.listingErrorWidget(state);
        }
        return _buildList(state);
      },
    );
  }

  Widget _buildList(PaginatedListState<T> state) {
    final items = state.items;
    if (items.isEmpty) {
      return widget.noItemFoundBuilder(context);
    }
    final showPaginationFooter =
        state.hasMore && state is! PaginatedListError<T>;
    final itemCount = items.length + (showPaginationFooter ? 1 : 0);

    return ListView.builder(
      controller: widget.scrollController,
      reverse: widget.reverse,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => _itemBuilder(context, index, items),
    );
  }

  Widget _itemBuilder(BuildContext context, int index, List<T> items) {
    if (index < items.length) {
      return widget.listItemBuilder(items[index], context, index);
    }

    if (widget.cubit.state is! PaginatedListLoading<T>) {
      Future<void>.microtask(widget.cubit.loadMore);
    }
    return widget.loadingWidget();
  }
}
