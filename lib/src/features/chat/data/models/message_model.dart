import '../../../../core/network/codecs.dart';
import '../../domain/entities/message_entity.dart';

/// Firestore JSON ↔ [MessageEntity]. `sentAt` tolerates null while the
/// serverTimestamp sentinel is pending. `_id`, `_hasPendingWrites`, and
/// the Timestamp→DateTime conversion are handled by [FirebaseFirestoreClient].
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.authorId,
    required super.authorUsername,
    super.sentAt,
    super.isPending,
  });

  factory MessageModel.fromFirestore(JsonMap json) {
    return MessageModel(
      id: (json['_id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      authorId: (json['authorId'] as String?) ?? '',
      authorUsername: (json['authorUsername'] as String?) ?? 'anon',
      sentAt: json['sentAt'] as DateTime?,
      isPending: (json['_hasPendingWrites'] as bool?) ?? false,
    );
  }
}
