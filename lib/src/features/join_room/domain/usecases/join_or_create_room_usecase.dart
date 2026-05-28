import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room_entity.dart';
import '../repository/room_repository.dart';

class JoinOrCreateRoomUseCase extends UseCase<RoomEntity, JoinOrCreateRoomParams> {
  JoinOrCreateRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, RoomEntity>> call(JoinOrCreateRoomParams params) {
    return _repository.joinOrCreate(params);
  }
}

class JoinOrCreateRoomParams extends Equatable {
  const JoinOrCreateRoomParams({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}
