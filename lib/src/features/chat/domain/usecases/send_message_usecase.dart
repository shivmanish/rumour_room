import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/chat_repository.dart';

class SendMessageUseCase extends UseCase<Unit, SendMessageParams> {
  SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SendMessageParams params) {
    return _repository.sendMessage(
      roomCode: params.roomCode,
      text: params.text,
      authorId: params.authorId,
      authorUsername: params.authorUsername,
    );
  }
}

class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.roomCode,
    required this.text,
    required this.authorId,
    required this.authorUsername,
  });

  final String roomCode;
  final String text;
  final String authorId;
  final String authorUsername;

  @override
  List<Object?> get props => [roomCode, text, authorId, authorUsername];
}
