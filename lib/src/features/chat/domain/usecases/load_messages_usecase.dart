import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/pagination.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repository/chat_repository.dart';

class LoadMessagesUseCase
    extends UseCase<PaginatedResult<MessageEntity>, LoadMessagesParams> {
  LoadMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<MessageEntity>>> call(
    LoadMessagesParams params,
  ) {
    return _repository.loadMessages(
      roomCode: params.roomCode,
      pageSize: params.pageSize,
      startAfter: params.startAfter,
    );
  }
}

class LoadMessagesParams extends Equatable {
  const LoadMessagesParams({
    required this.roomCode,
    required this.pageSize,
    this.startAfter,
  });

  final String roomCode;
  final int pageSize;
  final PageCursor? startAfter;

  @override
  List<Object?> get props => [roomCode, pageSize, startAfter];
}
