class PaginatedResult<T> {
  const PaginatedResult({required this.items, this.nextCursor});

  final List<T> items;

  /// Pass to next call as `startAfter`. Null = no more pages.
  final PageCursor? nextCursor;
}

/// Opaque cursor — round-trip only, don't inspect.
abstract class PageCursor {
  const PageCursor();
}
