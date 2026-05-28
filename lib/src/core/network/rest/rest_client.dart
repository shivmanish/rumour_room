import '../codecs.dart';
import '../remote_client.dart';

/// REST-specific extras on top of [RemoteClient] — headers, query params,
/// list reads with a root-key unwrap.
abstract class RestClient extends RemoteClient {
  Future<T?> readWithQuery<T>(
    String path,
    Decoder<T> decoder, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// [rootKey] unwraps payloads like `{"results": [...]}`.
  Future<List<T>> readList<T>(
    String path,
    Decoder<T> decoder, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? rootKey,
  });
}
