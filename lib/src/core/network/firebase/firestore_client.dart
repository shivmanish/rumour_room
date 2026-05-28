import '../codecs.dart';
import '../pagination.dart';
import '../remote_client.dart';

/// Firestore-specific extras on top of [RemoteClient] — streams,
/// paginated queries, server-timestamp sentinel.
abstract class FirestoreClient extends RemoteClient {
  /// Idempotent — call once at boot, before any other Firestore use.
  Future<void> enablePersistence();

  /// Sentinel for "use the server's clock". Typed as Object to keep the
  /// SDK out of this contract.
  Object get serverTimestamp;

  Future<void> setMerging<T>(
    String path,
    T value,
    Encoder<T> encoder, {
    bool merge = true,
  });

  /// Idempotently add [value] to [arrayField] and keep [countField] in sync.
  Future<void> addToArrayAndUpdateCount({
    required String path,
    required String arrayField,
    required String countField,
    required String value,
  });

  Stream<T?> streamDoc<T>(String path, Decoder<T> decoder);

  Stream<List<T>> streamCollection<T>(
    String collectionPath,
    Decoder<T> decoder, {
    String? orderBy,
    bool descending = false,
    bool orderByDocumentId = false,
    int? limit,
  });

  Future<PaginatedResult<T>> queryPage<T>(
    String collectionPath,
    Decoder<T> decoder, {
    required String orderBy,
    bool descending = true,
    bool orderByDocumentId = false,
    required int limit,
    PageCursor? startAfter,
  });
}
