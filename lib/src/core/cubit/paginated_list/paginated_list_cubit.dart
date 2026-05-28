import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../error/failures.dart';
import '../../network/pagination.dart';
import 'paginated_list_state.dart';

/// Base for cursor-paginated lists. Subclasses implement [fetchPage].
abstract class PaginatedListCubit<T> extends Cubit<PaginatedListState<T>> {
  PaginatedListCubit({this.pageSize = 30}) : super(PaginatedListInitial<T>());

  final int pageSize;
  PageCursor? _cursor;

  Future<Either<Failure, PaginatedResult<T>>> fetchPage(PageCursor? cursor);

  Future<void> loadInitial() async {
    if (isClosed) return;
    if (state is! PaginatedListInitial<T>) return;

    emit(PaginatedListLoading<T>(isInitial: true));

    final result = await fetchPage(null);
    if (isClosed) return;
    result.fold((failure) => emit(PaginatedListError<T>(failure)), (page) {
      _cursor = page.nextCursor;
      emit(
        PaginatedListLoaded<T>(
          items: List.unmodifiable(page.items),
          hasMore: page.nextCursor != null,
        ),
      );
    });
  }

  Future<void> loadMore() async {
    if (isClosed) return;
    final current = state;
    if (current is! PaginatedListLoaded<T>) return;
    if (!current.hasMore) return;

    emit(
      PaginatedListLoading<T>(
        items: current.items,
        hasMore: current.hasMore,
        isInitial: false,
      ),
    );

    final result = await fetchPage(_cursor);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        PaginatedListError<T>(
          failure,
          items: current.items,
          hasMore: current.hasMore,
        ),
      ),
      (page) {
        _cursor = page.nextCursor;
        emit(
          PaginatedListLoaded<T>(
            items: List.unmodifiable([...current.items, ...page.items]),
            hasMore: page.nextCursor != null,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    if (isClosed) return;
    _cursor = null;
    emit(PaginatedListInitial<T>());
    await loadInitial();
  }
}
