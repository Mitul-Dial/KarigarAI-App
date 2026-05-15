import 'package:cloud_firestore/cloud_firestore.dart';

/// Persists chat under `chats/{uid}/messages/{messageId}`.
class ChatRepository {
  ChatRepository._();

  static final ChatRepository instance = ChatRepository._();

  CollectionReference<Map<String, dynamic>> _messages(String uid) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(uid)
          .collection('messages');

  Future<void> saveMessage({
    required String uid,
    required String text,
    required String role,
  }) async {
    await _messages(uid).add({
      'text': text,
      'role': role,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> loadMessages(String uid) async {
    final snapshot = await _messages(uid)
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'role': data['role'] as String? ?? 'agent',
        'text': data['text'] as String? ?? '',
      };
    }).toList();
  }
}
