import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/direct_message.dart';

/// Repository for direct chat messages between customer and provider.
/// Messages are stored under `requests/{requestId}/chat_messages/{messageId}`.
class DirectChatRepository {
  DirectChatRepository._();
  static final DirectChatRepository instance = DirectChatRepository._();

  CollectionReference<Map<String, dynamic>> _messages(String requestId) =>
      FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .collection('chat_messages');

  /// Watch real-time messages for a specific request, ordered by timestamp.
  Stream<List<DirectMessage>> watchMessages(String requestId) {
    return _messages(requestId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DirectMessage.fromMap(d.id, d.data()))
            .toList());
  }

  /// Send a new message in the direct chat.
  Future<void> sendMessage({
    required String requestId,
    required String senderUid,
    required String senderName,
    required String text,
  }) async {
    await _messages(requestId).add({
      'senderUid': senderUid,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message preview on the request document for chat list display
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': senderUid,
    });
  }
}
