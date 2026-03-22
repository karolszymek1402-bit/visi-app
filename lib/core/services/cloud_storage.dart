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
}

/// Provider cloud storage — domyślnie null (local-only mode).
/// Nadpisywany w main.dart gdy Firebase jest skonfigurowany.
final cloudStorageProvider = Provider<CloudStorage?>((ref) => null);
