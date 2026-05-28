import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/codecs.dart';
import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.code,
    super.memberIds,
    super.createdAt,
  });

  factory RoomModel.fromJson(JsonMap json) {
    final raw = json['memberIds'];
    final memberIds = raw is List
        ? raw.whereType<String>().toList(growable: false)
        : const <String>[];
    return RoomModel(
      code: (json['code'] as String?) ?? (json['_id'] as String? ?? ''),
      memberIds: memberIds,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
