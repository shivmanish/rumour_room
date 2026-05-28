import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/pagination.dart';
import '../../../../core/utils/result_guard.dart';
import '../../../join_room/domain/entities/room_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasource/chat_datasource.dart';

class ChatRepositoryImpl with ResultGuard implements ChatRepository {
  ChatRepositoryImpl({required this.dataSource});

  final ChatDataSource dataSource;

  @override
  Future<Either<Failure, PaginatedResult<MessageEntity>>> loadMessages({
    required String roomCode,
    required int pageSize,
    PageCursor? startAfter,
  }) {
    return guard<PaginatedResult<MessageEntity>>(() async {
      final page = await dataSource.loadMessages(
        roomCode: roomCode,
        pageSize: pageSize,
        startAfter: startAfter,
      );
      return PaginatedResult<MessageEntity>(
        items: page.items,
        nextCursor: page.nextCursor,
      );
    });
  }

  @override
  Stream<List<MessageEntity>> streamLatest({
    required String roomCode,
    required int limit,
  }) {
    // stream errors stay as stream errors — the cubit attaches onError
    return dataSource
        .streamLatest(roomCode: roomCode, limit: limit)
        .map((list) => list.cast<MessageEntity>());
  }

  @override
  Stream<RoomEntity?> streamRoom(String roomCode) =>
      dataSource.streamRoom(roomCode);

  @override
  Future<Either<Failure, Unit>> registerMember({
    required String roomCode,
    required String identityId,
  }) {
    return guard<Unit>(() async {
      await dataSource.registerMember(
        roomCode: roomCode,
        identityId: identityId,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String roomCode,
    required String text,
    required String authorId,
    required String authorUsername,
  }) {
    return guard<Unit>(() async {
      await dataSource.sendMessage(
        roomCode: roomCode,
        text: text,
        authorId: authorId,
        authorUsername: authorUsername,
      );
      return unit;
    });
  }
}
