import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/room_entity.dart';

sealed class JoinRoomState extends Equatable {
  const JoinRoomState();

  @override
  List<Object?> get props => const [];
}

final class JoinRoomInitial extends JoinRoomState {
  const JoinRoomInitial();
}

final class JoinRoomChecking extends JoinRoomState {
  const JoinRoomChecking(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}

final class JoinRoomSuccess extends JoinRoomState {
  const JoinRoomSuccess(this.room);
  final RoomEntity room;

  @override
  List<Object?> get props => [room];
}

final class JoinRoomFailure extends JoinRoomState {
  const JoinRoomFailure(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
