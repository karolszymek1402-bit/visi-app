import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstrakcja cloud storage — Source of Truth w chmurze.
/// Umożliwia testowanie bez Firebase SDK.
abstract class CloudStorage {
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>?> getDocument(String collection, String docId);

  Future<void> deleteDocument(String collection, String docId);

  Future<Map<String, Map<String, dynamic>>> getAllDocuments(String collection);
}

/// Implementacja Firestore — prawdziwa chmura.
class FirestoreCloudStorage implements CloudStorage {
  final FirebaseFirestore _firestore;

  FirestoreCloudStorage(this._firestore);

  @override
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  @override
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(
    String collection,
  ) async {
    final snapshot = await _firestore.collection(collection).get();
    return {
      for (final doc in snapshot.docs)
        if (doc.data().isNotEmpty) doc.id: doc.data(),
    };
  }
}

/// Provider cloud storage — domyślnie null (local-only mode).
/// Nadpisywany w main.dart gdy Firebase jest skonfigurowany.
final cloudStorageProvider = Provider<CloudStorage?>((ref) => null);
