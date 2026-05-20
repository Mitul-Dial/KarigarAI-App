import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
            .where((d) => d.data()['timestamp'] != null)
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
    // Step 1: Add the message to the chat_messages subcollection
    try {
      await _messages(requestId).add({
        'senderUid': senderUid,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[DirectChat] Failed to add message: $e');
      rethrow;
    }

    // Step 2: Update last message preview on the request document (best-effort)
    // This is separated so a permission error here won't affect the message itself.
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageBy': senderUid,
      });
    } catch (e) {
      // Non-critical: chat list preview won't update, but message is still sent
      debugPrint('[DirectChat] Failed to update lastMessage preview: $e');
    }
  }
}
