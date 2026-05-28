import '../../../../core/services/local_storage_service.dart';
import '../models/identity_model.dart';

/// Per-room identity cache.
abstract class IdentityLocalDataSource {
  Future<IdentityModel?> read(String roomCode);
  Future<void> write({
    required String roomCode,
    required IdentityModel identity,
  });
}

class IdentityLocalDataSourceImpl implements IdentityLocalDataSource {
  IdentityLocalDataSourceImpl(this._storage);

  final LocalStorageService _storage;

  static String _key(String roomCode) => 'rumour.identity:$roomCode';

  @override
  Future<IdentityModel?> read(String roomCode) {
    return _storage.read<IdentityModel>(
      _key(roomCode),
      IdentityModel.fromCache,
    );
  }

  @override
  Future<void> write({
    required String roomCode,
    required IdentityModel identity,
  }) {
    return _storage.write<IdentityModel>(
      _key(roomCode),
      identity,
      (m) => m.toCacheJson(),
    );
  }
}
