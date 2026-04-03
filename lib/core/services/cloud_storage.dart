import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Abstrakcja cloud storage — Source of Truth w chmurze.
/// Umożliwia testowanie bez Firebase SDK.
abstract class CloudStorage {
  /// Operacje na subcollection users/{userId}/{collection}/{docId}
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>?> getDocument(String collection, String docId);

  Future<void> deleteDocument(String collection, String docId);

  Future<Map<String, Map<String, dynamic>>> getAllDocuments(String collection);

  /// Operacje bezpośrednio na rootCollection/{docId} (np. users/{uid})
  Future<void> setRootDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>?> getRootDocument(
    String collection,
    String docId,
  );
}

/// Implementacja Firestore — zapisuje dane w subcollection users/{userId}/{collection}.
/// Każdy użytkownik ma własną izolowaną przestrzeń danych.
class FirestoreCloudStorage implements CloudStorage {
  final FirebaseFirestore _firestore;
  final String userId;

  FirestoreCloudStorage(this._firestore, {required this.userId});

  CollectionReference<Map<String, dynamic>> _col(String collection) {
    return _firestore.collection('users').doc(userId).collection(collection);
  }

  @override
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _col(collection).doc(docId).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final doc = await _col(collection).doc(docId).get();
    return doc.data();
  }

  @override
  Future<void> deleteDocument(String collection, String docId) async {
    await _col(collection).doc(docId).delete();
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(
    String collection,
  ) async {
    final snapshot = await _col(collection).get();
    return {
      for (final doc in snapshot.docs)
        if (doc.data().isNotEmpty) doc.id: doc.data(),
    };
  }

  @override
  Future<void> setRootDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getRootDocument(
    String collection,
    String docId,
  ) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }
}

/// Provider cloud storage — reaktywny. Tworzy instancję gdy użytkownik jest
/// zalogowany (userId != null i != 'local_user'), zwraca null w trybie local-only.
final cloudStorageProvider = Provider<CloudStorage?>((ref) {
  final uid = ref.watch(authProvider).valueOrNull?.userId;
  if (uid == null || uid == 'local_user') return null;
  return FirestoreCloudStorage(FirebaseFirestore.instance, userId: uid);
});
