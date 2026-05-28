import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/pagination.dart';
import '../../../join_room/domain/entities/room_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, PaginatedResult<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    PageCursor? startAfter,
  });

  Stream<List<MessageEntity>> streamLatest({
    required String roomCode,
    required int limit,
  });

  Stream<RoomEntity?> streamRoom(String roomCode);

  /// Idempotent — safe to call on every chat-screen mount.
  Future<Either<Failure, Unit>> registerMember({
    required String roomCode,
    required String identityId,
  });

  Future<Either<Failure, Unit>> sendMessage({
    required String roomCode,
    required String text,
    required String authorId,
    required String authorUsername,
  });
}
