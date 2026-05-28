import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/room_entity.dart';
import '../usecases/join_or_create_room_usecase.dart';

abstract class RoomRepository {
  /// Idempotent — fetch or create.
  Future<Either<Failure, RoomEntity>> joinOrCreate(
    JoinOrCreateRoomParams params,
  );
}
