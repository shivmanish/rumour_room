import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorUsername,
    this.sentAt,
    this.isPending = false,
  });

  final String id;
  final String text;
  final String authorId;
  final String authorUsername;

  /// null while a serverTimestamp sentinel hasn't resolved (offline send).
  final DateTime? sentAt;

  /// true while Firestore still has the write queued — drives the
  /// clock-vs-check icon on outgoing bubbles.
  final bool isPending;

  bool isAuthoredBy(String identityId) => authorId == identityId;

  @override
  List<Object?> get props =>
      [id, text, authorId, authorUsername, sentAt, isPending];
}
