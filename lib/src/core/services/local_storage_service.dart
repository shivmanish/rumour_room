import '../network/codecs.dart';

/// Key-value local storage. Backed by shared_preferences.
abstract class LocalStorageService {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);

  Future<T?> read<T>(String key, Decoder<T> decoder);
  Future<void> write<T>(String key, T value, Encoder<T> encoder);

  Future<void> remove(String key);
  Future<bool> containsKey(String key);
}
