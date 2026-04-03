import 'package:visi/core/services/cloud_storage.dart';

/// In-memory fake cloud storage do testów (bez Firebase SDK).
class FakeCloudStorage implements CloudStorage {
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  @override
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    _store.putIfAbsent(collection, () => {})[docId] = Map.from(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    return _store[collection]?[docId];
  }

  /// Sprawdź czy dokument istnieje.
  bool hasDocument(String collection, String docId) {
    return _store[collection]?.containsKey(docId) ?? false;
  }

  @override
  Future<void> deleteDocument(String collection, String docId) async {
    _store[collection]?.remove(docId);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(
    String collection,
  ) async {
    return Map.from(_store[collection] ?? {});
  }

  @override
  Future<void> setRootDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    _store.putIfAbsent(collection, () => {})[docId] = Map.from(data);
  }

  @override
  Future<Map<String, dynamic>?> getRootDocument(
    String collection,
    String docId,
  ) async {
    return _store[collection]?[docId];
  }
}
