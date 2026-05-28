import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  const RoomEntity({
    required this.code,
    this.memberIds = const [],
    this.createdAt,
  });

  /// 6-digit code = Firestore document id.
  final String code;

  final List<String> memberIds;

  /// null while the serverTimestamp sentinel hasn't resolved yet.
  final DateTime? createdAt;

  int get memberCount => memberIds.length;

  RoomEntity copyWith({
    String? code,
    List<String>? memberIds,
    DateTime? createdAt,
  }) => RoomEntity(
    code: code ?? this.code,
    memberIds: memberIds ?? this.memberIds,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [code, memberIds, createdAt];
}
