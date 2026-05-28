import '../../../../core/network/codecs.dart';
import '../../../../core/network/firebase/firestore_client.dart';
import '../models/room_model.dart';

abstract class RoomDataSource {
  /// Returns the room or null if it doesn't exist.
  Future<RoomModel?> fetch(String code);

  /// Creates `rooms/{code}` with serverTimestamp. Membership is populated
  /// later by the first device to register.
  Future<RoomModel> create(String code);
}

class RoomFirestoreDataSourceImpl implements RoomDataSource {
  RoomFirestoreDataSourceImpl(this._client);

  final FirestoreClient _client;

  static String _path(String code) => 'rooms/$code';

  @override
  Future<RoomModel?> fetch(String code) {
    return _client.read<RoomModel>(_path(code), RoomModel.fromJson);
  }

  @override
  Future<RoomModel> create(String code) async {
    final data = <String, dynamic>{
      'code': code,
      'createdAt': _client.serverTimestamp,
    };
    await _client.set<JsonMap>(_path(code), data, _identityEncoder);
    return RoomModel(code: code);
  }

  static JsonMap _identityEncoder(JsonMap value) => value;
}
