import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/connectivity_service.dart';
import '../../error/exceptions.dart';
import '../codecs.dart';
import '../pagination.dart';
import 'firestore_client.dart';

/// cloud_firestore implementation of [FirestoreClient].
/// Note: docs come back with Firestore types (Timestamp etc.) — DTOs decode them.
class FirebaseFirestoreClient implements FirestoreClient {
  FirebaseFirestoreClient(
    this._connectivity, [
    FirebaseFirestore? firestore,
  ]) : _firestore = firestore ?? FirebaseFirestore.instance;

  final ConnectivityService _connectivity;
  final FirebaseFirestore _firestore;
  bool _persistenceConfigured = false;

  // pick cache directly when offline so .get() doesn't sit waiting for the
  // server to time out before falling back
  Future<GetOptions> _getOptions() async {
    final status = await _connectivity.currentStatus();
    return status == ConnectivityStatus.offline
        ? const GetOptions(source: Source.cache)
        : const GetOptions(source: Source.serverAndCache);
  }

  @override
  Future<void> enablePersistence() async {
    if (_persistenceConfigured) return;
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {
      // settings can only be set once per app launch — ignore on hot restart
    }
    _persistenceConfigured = true;
  }

  @override
  Object get serverTimestamp => FieldValue.serverTimestamp();

  @override
  Future<void> setMerging<T>(
    String path,
    T value,
    Encoder<T> encoder, {
    bool merge = true,
  }) async {
    try {
      await _firestore.doc(path).set(encoder(value), SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore set failed.',
        code: e.code,
      );
    }
  }

  @override
  Future<void> addToArrayAndUpdateCount({
    required String path,
    required String arrayField,
    required String countField,
    required String value,
  }) async {
    try {
      final ref = _firestore.doc(path);
      await _firestore.runTransaction<void>((transaction) async {
        final snap = await transaction.get(ref);
        if (!snap.exists) {
          throw NotFoundException('No document at $path.');
        }

        final data = snap.data() ?? const <String, dynamic>{};
        final rawItems = data[arrayField];
        final items = rawItems is List
            ? rawItems.whereType<String>().toSet()
            : <String>{};
        items.add(value);

        transaction.update(ref, <String, dynamic>{
          arrayField: items.toList(growable: false),
          countField: items.length,
        });
      });
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore transaction failed.',
        code: e.code,
      );
    }
  }

  @override
  Stream<T?> streamDoc<T>(String path, Decoder<T> decoder) {
    // includeMetadataChanges so pending-write → synced flips emit too
    // (needed for the clock → check icon on outgoing bubbles)
    return _firestore.doc(path).snapshots(includeMetadataChanges: true).map((
      snap,
    ) {
      if (!snap.exists) return null;
      return decoder(_inject(snap.id, snap.data(), snap.metadata));
    });
  }

  @override
  Stream<List<T>> streamCollection<T>(
    String collectionPath,
    Decoder<T> decoder, {
    String? orderBy,
    bool descending = false,
    bool orderByDocumentId = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (orderBy != null && orderByDocumentId) {
      query = query.orderBy(FieldPath.documentId, descending: descending);
    }
    if (limit != null) query = query.limit(limit);

    return query
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map((d) => decoder(_inject(d.id, d.data(), d.metadata)))
              .toList(growable: false),
        );
  }

  @override
  Future<PaginatedResult<T>> queryPage<T>(
    String collectionPath,
    Decoder<T> decoder, {
    required String orderBy,
    bool descending = true,
    bool orderByDocumentId = false,
    required int limit,
    PageCursor? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(collectionPath)
          .orderBy(orderBy, descending: descending);

      if (orderByDocumentId) {
        query = query.orderBy(FieldPath.documentId, descending: descending);
      }

      query = query.limit(limit);

      if (startAfter is _SnapshotCursor) {
        query = query.startAfterDocument(startAfter.snapshot);
      }

      final snap = await query.get(await _getOptions());
      final items = snap.docs
          .map((d) => decoder(_inject(d.id, d.data(), d.metadata)))
          .toList(growable: false);
      final last = snap.docs.isEmpty ? null : snap.docs.last;
      final nextCursor = (last == null || items.length < limit)
          ? null
          : _SnapshotCursor(last);
      return PaginatedResult<T>(items: items, nextCursor: nextCursor);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore query failed.',
        code: e.code,
      );
    }
  }

  /// Injects `_id` and `_hasPendingWrites` into the map so decoders can
  /// read them without us widening the [Decoder<T>] signature.
  Map<String, dynamic> _inject(
    String id,
    Map<String, dynamic>? data,
    SnapshotMetadata metadata,
  ) {
    final out = Map<String, dynamic>.from(data ?? const {});
    out['_id'] = id;
    out['_hasPendingWrites'] = metadata.hasPendingWrites;
    return out;
  }

  @override
  Future<T?> read<T>(String path, Decoder<T> decoder) async {
    try {
      final snap = await _firestore.doc(path).get(await _getOptions());
      if (!snap.exists) return null;
      return decoder(_inject(snap.id, snap.data(), snap.metadata));
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore read failed.',
        code: e.code,
      );
    }
  }

  @override
  Future<void> set<T>(String path, T value, Encoder<T> encoder) async {
    try {
      await _firestore.doc(path).set(encoder(value));
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore write failed.',
        code: e.code,
      );
    }
  }

  @override
  Future<String> add<T>(
    String collectionPath,
    T value,
    Encoder<T> encoder,
  ) async {
    try {
      final ref = await _firestore
          .collection(collectionPath)
          .add(encoder(value));
      return ref.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore add failed.',
        code: e.code,
      );
    }
  }

  @override
  Future<void> update<T>(String path, T value, Encoder<T> encoder) async {
    try {
      await _firestore.doc(path).update(encoder(value));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw NotFoundException('No document at $path.');
      }
      throw FirestoreException(
        e.message ?? 'Firestore update failed.',
        code: e.code,
      );
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _firestore.doc(path).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        e.message ?? 'Firestore delete failed.',
        code: e.code,
      );
    }
  }
}

class _SnapshotCursor extends PageCursor {
  const _SnapshotCursor(this.snapshot);
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
}
