import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  // Collection references
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get notesCollection =>
      _firestore.collection('notes');

  CollectionReference<Map<String, dynamic>> get utilitiesCollection =>
      _firestore.collection('utilities');

  /// Save or update user profile document
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile in Firestore: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    return await usersCollection.doc(uid).get();
  }

  /// Create a note in Firestore
  Future<DocumentReference<Map<String, dynamic>>> createNote({
    required String userId,
    required Map<String, dynamic> noteData,
  }) async {
    try {
      return await notesCollection.add({
        ...noteData,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating note in Firestore: $e');
      rethrow;
    }
  }

  /// Stream of user notes
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserNotes(String userId) {
    return notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update a note
  Future<void> updateNote({
    required String noteId,
    required Map<String, dynamic> noteData,
  }) async {
    try {
      await notesCollection.doc(noteId).update({
        ...noteData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating note in Firestore: $e');
      rethrow;
    }
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await notesCollection.doc(noteId).delete();
    } catch (e) {
      debugPrint('Error deleting note in Firestore: $e');
      rethrow;
    }
  }
}
