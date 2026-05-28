import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rumour_room/src/core/error/failures.dart';
import 'package:rumour_room/src/features/join_room/domain/entities/room_entity.dart';
import 'package:rumour_room/src/features/join_room/domain/usecases/join_or_create_room_usecase.dart';
import 'package:rumour_room/src/features/join_room/presentation/cubit/join_room/join_room_cubit.dart';
import 'package:rumour_room/src/features/join_room/presentation/cubit/join_room/join_room_state.dart';

class _MockUseCase extends Mock implements JoinOrCreateRoomUseCase {}

class _FakeParams extends Fake implements JoinOrCreateRoomParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeParams());
  });

  late _MockUseCase useCase;

  setUp(() {
    useCase = _MockUseCase();
  });

  JoinRoomCubit build() =>
      JoinRoomCubit(joinOrCreateUseCase: useCase);

  group('JoinRoomCubit.submit', () {
    blocTest<JoinRoomCubit, JoinRoomState>(
      'emits Failure(ValidationFailure) when code is not 6 digits, '
      'without calling the use case',
      build: build,
      act: (cubit) => cubit.submit('123'),
      expect: () => [
        isA<JoinRoomFailure>().having(
          (s) => s.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      ],
      verify: (_) => verifyNever(() => useCase.call(any())),
    );

    blocTest<JoinRoomCubit, JoinRoomState>(
      'emits Checking → Success when the use case returns a room',
      build: () {
        when(() => useCase.call(any())).thenAnswer(
          (_) async => const Right(
            RoomEntity(code: '123456', memberIds: ['device-uuid']),
          ),
        );
        return build();
      },
      act: (cubit) => cubit.submit('123456'),
      expect: () => [
        const JoinRoomChecking('123456'),
        isA<JoinRoomSuccess>().having(
          (s) => s.room.code,
          'room.code',
          '123456',
        ),
      ],
    );

    blocTest<JoinRoomCubit, JoinRoomState>(
      'emits Checking → Failure when the use case returns Left(failure)',
      build: () {
        when(() => useCase.call(any())).thenAnswer(
          (_) async => const Left(NetworkFailure('offline')),
        );
        return build();
      },
      act: (cubit) => cubit.submit('123456'),
      expect: () => [
        const JoinRoomChecking('123456'),
        isA<JoinRoomFailure>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });

  group('JoinRoomCubit.reset', () {
    blocTest<JoinRoomCubit, JoinRoomState>(
      'returns the cubit to the initial state',
      build: build,
      seed: () => const JoinRoomFailure(NetworkFailure('boom')),
      act: (cubit) => cubit.reset(),
      expect: () => [isA<JoinRoomInitial>()],
    );
  });
}
