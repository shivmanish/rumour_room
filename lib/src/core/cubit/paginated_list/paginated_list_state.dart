import 'package:equatable/equatable.dart';

import '../../error/failures.dart';

/// All variants carry [items] + [hasMore] so the UI can keep rendering the
/// known list during a load-more or after an error.
sealed class PaginatedListState<T> extends Equatable {
  const PaginatedListState({
    this.items = const [],
    this.hasMore = false,
  });

  final List<T> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}

final class PaginatedListInitial<T> extends PaginatedListState<T> {
  const PaginatedListInitial();
}

final class PaginatedListLoading<T> extends PaginatedListState<T> {
  const PaginatedListLoading({
    super.items,
    super.hasMore,
    required this.isInitial,
  });

  /// true = first load, false = tail (load-more).
  final bool isInitial;

  @override
  List<Object?> get props => [...super.props, isInitial];
}

final class PaginatedListLoaded<T> extends PaginatedListState<T> {
  const PaginatedListLoaded({
    required super.items,
    required super.hasMore,
  });
}

final class PaginatedListError<T> extends PaginatedListState<T> {
  const PaginatedListError(this.failure, {super.items, super.hasMore});

  final Failure failure;

  @override
  List<Object?> get props => [...super.props, failure];
}
