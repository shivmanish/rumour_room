import '../../../../../core/cubit/base_cubit.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/room_code_generator.dart';
import '../../../domain/entities/room_entity.dart';
import '../../../domain/usecases/join_or_create_room_usecase.dart';
import 'join_room_state.dart';

/// Business state for the Join screen — validates + join-or-create.
/// Form state (controllers, current code) lives in [RoomCodeFormCubit].
class JoinRoomCubit
    extends BaseCubit<JoinRoomState, RoomEntity, JoinOrCreateRoomParams> {
  JoinRoomCubit({required JoinOrCreateRoomUseCase joinOrCreateUseCase})
    : super(
        initialState: const JoinRoomInitial(),
        useCase: joinOrCreateUseCase,
      );

  Future<void> submit(String code) async {
    if (!RoomCodeGenerator.isValid(code)) {
      safeEmit(
        const JoinRoomFailure(
          ValidationFailure('Enter a valid 6-digit room code.'),
        ),
      );
      return;
    }

    safeEmit(JoinRoomChecking(code));

    final result = await useCase!.call(JoinOrCreateRoomParams(code: code));
    if (isClosed) return;

    result.fold(
      (failure) => safeEmit(JoinRoomFailure(failure)),
      (room) => safeEmit(JoinRoomSuccess(room)),
    );
  }

  void reset() => safeEmit(const JoinRoomInitial());
}
