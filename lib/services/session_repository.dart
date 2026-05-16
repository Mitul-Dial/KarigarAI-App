import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session.dart';
import '../models/service_intent.dart';

class SessionRepository {
  SessionRepository._();
  static final SessionRepository instance = SessionRepository._();

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> _messages(String uid, String sessionId) =>
      _sessions(uid).doc(sessionId).collection('messages');

  Future<List<ChatSession>> listSessions(String uid) async {
    final snap = await _sessions(uid).orderBy('updatedAt', descending: true).get();
    return snap.docs.map((d) => ChatSession.fromMap(d.id, d.data())).toList();
  }

  Future<String> createSession(String uid, {String title = 'New chat'}) async {
    final ref = _sessions(uid).doc();
    final now = DateTime.now();
    await ref.set({
      'title': title,
      'createdAt': now,
      'updatedAt': now,
      'intentSummary': '',
    });
    return ref.id;
  }

  Future<void> touchSession(String uid, String sessionId, {String? intentSummary}) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (intentSummary != null) data['intentSummary'] = intentSummary;
    await _sessions(uid).doc(sessionId).update(data);
  }

  Future<ServiceIntent> loadIntent(String uid, String sessionId) async {
    final snap = await _sessions(uid).doc(sessionId).get();
    return ServiceIntent.fromMap(snap.data()?['intent'] as Map<String, dynamic>?);
  }

  Future<void> saveIntent(String uid, String sessionId, ServiceIntent intent) async {
    await _sessions(uid).doc(sessionId).set({
      'intent': intent.toMap(),
      'intentSummary': intent.summary(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<String>> loadRejectedIds(String uid, String sessionId) async {
    final snap = await _sessions(uid).doc(sessionId).get();
    final list = snap.data()?['rejectedProviderIds'] as List?;
    return list?.map((e) => e.toString()).toList() ?? [];
  }

  Future<void> saveRejectedIds(
    String uid,
    String sessionId,
    List<String> ids,
  ) async {
    await _sessions(uid).doc(sessionId).set({
      'rejectedProviderIds': ids,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> loadMessages(String uid, String sessionId) async {
    final snap = await _messages(uid, sessionId).orderBy('timestamp').get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'role': data['role'],
        'text': data['text'],
        if (data['provider'] != null) 'provider': data['provider'],
        if (data['booked'] == true) 'booked': true,
        if (data['requestId'] != null) 'requestId': data['requestId'],
      };
    }).toList();
  }

  /// Avoid duplicate status lines when Firestore listener and updateStatus both run.
  Future<void> saveMessageIfNew({
    required String uid,
    required String sessionId,
    required String role,
    required String text,
  }) async {
    final recent = await _messages(uid, sessionId)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
    for (final d in recent.docs) {
      final data = d.data();
      if (data['role'] == role && data['text'] == text) return;
    }
    await saveMessage(uid: uid, sessionId: sessionId, role: role, text: text);
  }

  Future<String> saveMessage({
    required String uid,
    required String sessionId,
    required String role,
    required String text,
    Map<String, dynamic>? provider,
    bool booked = false,
    String? requestId,
  }) async {
    final ref = await _messages(uid, sessionId).add({
      'role': role,
      'text': text,
      if (provider != null) 'provider': provider,
      if (booked) 'booked': true,
      if (requestId != null) 'requestId': requestId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await touchSession(uid, sessionId);
    return ref.id;
  }

  Future<void> markMessageBooked(
    String uid,
    String sessionId,
    String messageId, {
    required String requestId,
  }) async {
    await _messages(uid, sessionId).doc(messageId).update({
      'booked': true,
      'requestId': requestId,
    });
  }
}
