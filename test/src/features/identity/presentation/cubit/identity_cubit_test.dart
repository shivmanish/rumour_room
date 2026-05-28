import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rumour_room/src/core/error/failures.dart';
import 'package:rumour_room/src/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_room/src/features/identity/domain/repository/identity_repository.dart';
import 'package:rumour_room/src/features/identity/domain/usecases/get_or_fetch_identity_usecase.dart';
import 'package:rumour_room/src/features/identity/presentation/cubit/identity_cubit.dart';
import 'package:rumour_room/src/features/identity/presentation/cubit/identity_state.dart';

class _MockUseCase extends Mock implements GetOrFetchIdentityUseCase {}

class _FakeGetOrFetchIdentityParams extends Fake
    implements GetOrFetchIdentityParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeGetOrFetchIdentityParams());
  });

  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
  });

  IdentityCubit build() => IdentityCubit(getOrFetchUseCase: useCase);

  const sampleIdentity = IdentityEntity(
    id: 'uuid-1',
    displayName: 'Brave Badger',
    username: 'pinkpanthress',
  );
  const roomCode = '123456';

  group('IdentityCubit.load', () {
    blocTest<IdentityCubit, IdentityState>(
      'emits Loading → Loaded(isFresh: true) when the use case returns a fresh identity',
      build: () {
        when(() => useCase.call(any())).thenAnswer(
          (_) async => const Right(
            ResolvedIdentity(identity: sampleIdentity, isFresh: true),
          ),
        );
        return build();
      },
      act: (cubit) => cubit.load(roomCode),
      expect: () => [
        const IdentityLoading(),
        const IdentityLoaded(identity: sampleIdentity, isFresh: true),
      ],
    );

    blocTest<IdentityCubit, IdentityState>(
      'emits Loading → Loaded(isFresh: false) when the use case returns a cached identity',
      build: () {
        when(() => useCase.call(any())).thenAnswer(
          (_) async => const Right(
            ResolvedIdentity(identity: sampleIdentity, isFresh: false),
          ),
        );
        return build();
      },
      act: (cubit) => cubit.load(roomCode),
      expect: () => [
        const IdentityLoading(),
        const IdentityLoaded(identity: sampleIdentity, isFresh: false),
      ],
    );

    blocTest<IdentityCubit, IdentityState>(
      'emits Loading → Failure on Left(failure)',
      build: () {
        when(
          () => useCase.call(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure('offline')));
        return build();
      },
      act: (cubit) => cubit.load(roomCode),
      expect: () => [
        const IdentityLoading(),
        isA<IdentityFailure>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });

  group('IdentityCubit.acknowledgeReveal', () {
    blocTest<IdentityCubit, IdentityState>(
      'flips isFresh from true → false',
      build: build,
      seed: () => const IdentityLoaded(identity: sampleIdentity, isFresh: true),
      act: (cubit) => cubit.acknowledgeReveal(),
      expect: () => [
        const IdentityLoaded(identity: sampleIdentity, isFresh: false),
      ],
    );

    blocTest<IdentityCubit, IdentityState>(
      'is a no-op when isFresh is already false',
      build: build,
      seed: () =>
          const IdentityLoaded(identity: sampleIdentity, isFresh: false),
      act: (cubit) => cubit.acknowledgeReveal(),
      expect: () => <IdentityState>[],
    );

    blocTest<IdentityCubit, IdentityState>(
      'is a no-op when state is not Loaded',
      build: build,
      act: (cubit) => cubit.acknowledgeReveal(),
      expect: () => <IdentityState>[],
    );
  });
}
