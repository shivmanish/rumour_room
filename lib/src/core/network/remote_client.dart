import 'codecs.dart';

/// Common surface over any remote source — REST, Firestore, future RPC.
abstract class RemoteClient {
  Future<T?> read<T>(String path, Decoder<T> decoder);

  Future<void> set<T>(String path, T value, Encoder<T> encoder);

  /// Append to a collection — returns the server-allocated id.
  Future<String> add<T>(String collectionPath, T value, Encoder<T> encoder);

  Future<void> update<T>(String path, T value, Encoder<T> encoder);

  Future<void> delete(String path);
}
