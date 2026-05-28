import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import '../network/codecs.dart';
import 'local_storage_service.dart';

class SharedPreferencesLocalStorage implements LocalStorageService {
  SharedPreferencesLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    final ok = await _prefs.setString(key, value);
    if (!ok) throw CacheException('Failed to persist "$key".');
  }

  @override
  Future<T?> read<T>(String key, Decoder<T> decoder) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw CacheException('Stored value at "$key" is not a JSON object.');
      }
      return decoder(decoded);
    } on FormatException {
      throw CacheException('Stored value at "$key" is not valid JSON.');
    }
  }

  @override
  Future<void> write<T>(String key, T value, Encoder<T> encoder) async {
    final encoded = jsonEncode(encoder(value));
    final ok = await _prefs.setString(key, encoded);
    if (!ok) throw CacheException('Failed to persist "$key".');
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);
}
