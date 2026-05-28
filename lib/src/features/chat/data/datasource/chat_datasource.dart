import '../../../../core/network/codecs.dart';
import '../../../../core/network/firebase/firestore_client.dart';
import '../../../../core/network/pagination.dart';
import '../../../join_room/data/models/room_model.dart';
import '../models/message_model.dart';

abstract class ChatDataSource {
  Future<PaginatedResult<MessageModel>> loadMessages({
    required String roomCode,
    required int pageSize,
    PageCursor? startAfter,
  });

  Stream<List<MessageModel>> streamLatest({
    required String roomCode,
    required int limit,
  });

  Stream<RoomModel?> streamRoom(String roomCode);

  Future<void> registerMember({
    required String roomCode,
    required String identityId,
  });

  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required String authorId,
    required String authorUsername,
  });
}

class ChatFirestoreDataSourceImpl implements ChatDataSource {
  ChatFirestoreDataSourceImpl(this._client);

  final FirestoreClient _client;

  static String _messagesPath(String roomCode) => 'rooms/$roomCode/messages';
  static String _roomPath(String roomCode) => 'rooms/$roomCode';

  @override
  Future<PaginatedResult<MessageModel>> loadMessages({
    required String roomCode,
    required int pageSize,
    PageCursor? startAfter,
  }) {
    return _client.queryPage<MessageModel>(
      _messagesPath(roomCode),
      MessageModel.fromFirestore,
      orderBy: 'sentAt',
      descending: true,
      orderByDocumentId: true,
      limit: pageSize,
      startAfter: startAfter,
    );
  }

  @override
  Stream<List<MessageModel>> streamLatest({
    required String roomCode,
    required int limit,
  }) {
    return _client.streamCollection<MessageModel>(
      _messagesPath(roomCode),
      MessageModel.fromFirestore,
      orderBy: 'sentAt',
      descending: true,
      orderByDocumentId: true,
      limit: limit,
    );
  }

  @override
  Stream<RoomModel?> streamRoom(String roomCode) {
    return _client.streamDoc<RoomModel>(
      _roomPath(roomCode),
      RoomModel.fromJson,
    );
  }

  @override
  Future<void> registerMember({
    required String roomCode,
    required String identityId,
  }) async {
    await _client.addToArrayAndUpdateCount(
      path: _roomPath(roomCode),
      arrayField: 'memberIds',
      countField: 'memberCount',
      value: identityId,
    );
  }

  @override
  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required String authorId,
    required String authorUsername,
  }) async {
    final data = <String, dynamic>{
      'text': text,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'sentAt': _client.serverTimestamp,
    };
    await _client.add<JsonMap>(_messagesPath(roomCode), data, (m) => m);
  }
}
