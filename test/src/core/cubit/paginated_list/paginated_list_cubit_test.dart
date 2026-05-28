import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumour_room/src/core/cubit/paginated_list/paginated_list_cubit.dart';
import 'package:rumour_room/src/core/cubit/paginated_list/paginated_list_state.dart';
import 'package:rumour_room/src/core/error/failures.dart';
import 'package:rumour_room/src/core/network/pagination.dart';

class _Cursor extends PageCursor {
  const _Cursor(this.value);
  final int value;

  @override
  bool operator ==(Object other) => other is _Cursor && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

typedef _Fetcher = Future<Either<Failure, PaginatedResult<String>>> Function(
  PageCursor? cursor,
);

class _TestCubit extends PaginatedListCubit<String> {
  _TestCubit(this.fetcher);

  _Fetcher fetcher;
  final cursors = <PageCursor?>[];

  @override
  Future<Either<Failure, PaginatedResult<String>>> fetchPage(
    PageCursor? cursor,
  ) {
    cursors.add(cursor);
    return fetcher(cursor);
  }
}

void main() {
  group('PaginatedListCubit.loadInitial', () {
    test('Initial → Loading(initial) → Loaded with first-page items',
        () async {
      final cubit = _TestCubit(
        (_) async => const Right(
          PaginatedResult<String>(items: ['a', 'b', 'c'], nextCursor: _Cursor(1)),
        ),
      );
      addTearDown(cubit.close);

      final emitted = <PaginatedListState<String>>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadInitial();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted, hasLength(2));
      expect(emitted[0], isA<PaginatedListLoading<String>>());
      expect((emitted[0] as PaginatedListLoading<String>).isInitial, isTrue);
      expect(emitted[1], isA<PaginatedListLoaded<String>>());
      final loaded = emitted[1] as PaginatedListLoaded<String>;
      expect(loaded.items, ['a', 'b', 'c']);
      expect(loaded.hasMore, isTrue);
    });

    test('sets hasMore=false when no next cursor', () async {
      final cubit = _TestCubit(
        (_) async => const Right(
          PaginatedResult<String>(items: ['only'], nextCursor: null),
        ),
      );
      addTearDown(cubit.close);

      await cubit.loadInitial();

      final state = cubit.state;
      expect(state, isA<PaginatedListLoaded<String>>());
      expect((state as PaginatedListLoaded<String>).hasMore, isFalse);
    });

    test('emits Error when fetchPage returns Left', () async {
      final cubit = _TestCubit(
        (_) async => const Left(NetworkFailure('offline')),
      );
      addTearDown(cubit.close);

      await cubit.loadInitial();

      expect(cubit.state, isA<PaginatedListError<String>>());
      expect(
        (cubit.state as PaginatedListError<String>).failure,
        isA<NetworkFailure>(),
      );
    });

    test('is a no-op when state is not Initial', () async {
      final cubit = _TestCubit(
        (_) async => const Right(
          PaginatedResult<String>(items: ['a'], nextCursor: null),
        ),
      );
      addTearDown(cubit.close);
      await cubit.loadInitial();
      cubit.cursors.clear();

      await cubit.loadInitial();

      expect(cubit.cursors, isEmpty);
    });
  });

  group('PaginatedListCubit.loadMore', () {
    test('advances cursor and appends second-page items', () async {
      var call = 0;
      final cubit = _TestCubit((cursor) async {
        call++;
        if (call == 1) {
          return const Right(
            PaginatedResult<String>(
              items: ['a', 'b', 'c'],
              nextCursor: _Cursor(1),
            ),
          );
        }
        expect(cursor, const _Cursor(1));
        return const Right(
          PaginatedResult<String>(items: ['d', 'e'], nextCursor: null),
        );
      });
      addTearDown(cubit.close);

      await cubit.loadInitial();
      await cubit.loadMore();

      expect(cubit.cursors, [null, const _Cursor(1)]);
      final state = cubit.state as PaginatedListLoaded<String>;
      expect(state.items, ['a', 'b', 'c', 'd', 'e']);
      expect(state.hasMore, isFalse);
    });

    test('no-ops when not in Loaded state', () async {
      final cubit = _TestCubit(
        (_) async => const Right(
          PaginatedResult<String>(items: ['a'], nextCursor: null),
        ),
      );
      addTearDown(cubit.close);

      await cubit.loadMore();

      expect(cubit.cursors, isEmpty);
      expect(cubit.state, isA<PaginatedListInitial<String>>());
    });

    test('no-ops when hasMore=false', () async {
      final cubit = _TestCubit(
        (_) async => const Right(
          PaginatedResult<String>(items: ['a'], nextCursor: null),
        ),
      );
      addTearDown(cubit.close);
      await cubit.loadInitial();
      cubit.cursors.clear();

      await cubit.loadMore();

      expect(cubit.cursors, isEmpty);
    });

    test('keeps existing items on Error during load-more', () async {
      var call = 0;
      final cubit = _TestCubit((cursor) async {
        call++;
        if (call == 1) {
          return const Right(
            PaginatedResult<String>(
              items: ['a', 'b'],
              nextCursor: _Cursor(1),
            ),
          );
        }
        return const Left(UnknownFailure('boom'));
      });
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await cubit.loadMore();

      final state = cubit.state;
      expect(state, isA<PaginatedListError<String>>());
      expect((state as PaginatedListError<String>).items, ['a', 'b']);
      expect(state.hasMore, isTrue);
    });
  });

  group('PaginatedListCubit.refresh', () {
    test('resets cursor and re-runs loadInitial', () async {
      var call = 0;
      final cubit = _TestCubit((cursor) async {
        call++;
        return Right(
          PaginatedResult<String>(
            items: ['call-$call'],
            nextCursor: null,
          ),
        );
      });
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await cubit.refresh();

      final state = cubit.state as PaginatedListLoaded<String>;
      expect(state.items, ['call-2']);
      expect(cubit.cursors, [null, null]);
    });
  });
}
