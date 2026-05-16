import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/labour_provider.dart';
import '../models/service_intent.dart';
import '../models/service_request.dart';
import 'session_repository.dart';

class RequestsRepository {
  RequestsRepository._();
  static final RequestsRepository instance = RequestsRepository._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('requests');

  Stream<List<ServiceRequest>> watchCustomerRequests(String customerUid) {
    return _col.where('customerUid', isEqualTo: customerUid).snapshots().map(
          (s) {
            final list = s.docs
                .map((d) => ServiceRequest.fromMap(d.id, d.data()))
                .toList();
            list.sort((a, b) =>
                (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
            return list;
          },
        );
  }

  Stream<List<ServiceRequest>> watchProviderInbox({
    required String providerService,
    required bool isOnline,
  }) {
    if (!isOnline) return Stream.value([]);
    return _col.where('status', isEqualTo: 'PENDING').snapshots().map((s) {
      return s.docs
          .map((d) => ServiceRequest.fromMap(d.id, d.data()))
          .where((r) => r.service == providerService)
          .toList();
    });
  }

  Stream<List<ServiceRequest>> watchProviderActive(String providerUid) {
    return _col.where('providerUid', isEqualTo: providerUid).snapshots().map(
          (s) => s.docs
              .map((d) => ServiceRequest.fromMap(d.id, d.data()))
              .where((r) => r.status != 'PENDING' && r.status != 'DECLINED')
              .toList(),
        );
  }

  static const _activeStatuses = {
    'PENDING',
    'ACCEPTED',
    'ON_THE_WAY',
    'ARRIVED',
    'COMPLETION_REQUESTED',
    'COMPLETED',
  };

  /// True if this chat session has no in-progress booking.
  Future<bool> sessionCanStartNewBooking({
    required String customerUid,
    required String sessionId,
  }) async {
    final snap = await _col
        .where('customerUid', isEqualTo: customerUid)
        .where('sessionId', isEqualTo: sessionId)
        .get();
    for (final d in snap.docs) {
      final st = d.data()['status'] as String? ?? '';
      if (_activeStatuses.contains(st)) return false;
    }
    return true;
  }

  Future<bool> hasPendingBookingForProvider({
    required String customerUid,
    required String providerId,
    required String sessionId,
  }) async {
    final snap = await _col
        .where('customerUid', isEqualTo: customerUid)
        .where('sessionId', isEqualTo: sessionId)
        .get();
    for (final d in snap.docs) {
      final data = d.data();
      final snapProv = data['providerSnapshot'] as Map<String, dynamic>?;
      final pid = snapProv?['id'] as String?;
      final st = data['status'] as String?;
      if (pid == providerId && st != 'DECLINED' && st != 'RATED') {
        return true;
      }
    }
    return false;
  }

  Future<ServiceRequest> createFromBooking({
    required String customerUid,
    required String customerName,
    required ServiceIntent intent,
    required LabourProvider provider,
    required String sessionId,
  }) async {
    final exists = await hasPendingBookingForProvider(
      customerUid: customerUid,
      providerId: provider.id,
      sessionId: sessionId,
    );
    if (exists) {
      throw StateError('Request already sent for this provider');
    }

    final ref = _col.doc();
    final total = provider.priceEstimatePkr;
    final advance = (total * 0.1).round();
    final priceLabel = '$total PKR (Adv $advance PKR)';

    final req = ServiceRequest(
      id: ref.id,
      customerUid: customerUid,
      customerName: customerName,
      service: intent.service!,
      time: intent.time!,
      location: intent.location!,
      price: priceLabel,
      status: 'PENDING',
      providerName: provider.name,
      providerSnapshot: provider.toMap(),
      scheduledAt: _parseScheduledTime(intent.time!),
      createdAt: DateTime.now(),
      sessionId: sessionId,
    );
    await ref.set(req.toMap());
    return req;
  }

  static String? customerChatMessageForStatus(String status) {
    return switch (status) {
      'ACCEPTED' => 'Your request has been accepted by the provider.',
      'ON_THE_WAY' => 'Provider is on the way to your location.',
      'ARRIVED' => 'Provider has arrived at your location.',
      'COMPLETION_REQUESTED' =>
        'Provider has completed the job. Please verify in Requests tab.',
      'COMPLETED' => 'You verified the job. Please rate the provider (1–10) in Requests.',
      'RATED' =>
        'Thank you! Your rating and feedback have been submitted. You can book another service anytime.',
      _ => null,
    };
  }

  Future<void> updateStatus(
    String requestId,
    String status, {
    String? providerUid,
    String? providerName,
    int? rating,
    String? feedback,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (providerUid != null) data['providerUid'] = providerUid;
    if (providerName != null) data['providerName'] = providerName;
    if (rating != null) data['rating'] = rating;
    if (feedback != null) data['feedback'] = feedback;
    await _col.doc(requestId).update(data);

    final snap = await _col.doc(requestId).get();
    if (!snap.exists) return;
    final req = ServiceRequest.fromMap(requestId, snap.data()!);
    final chatMsg = customerChatMessageForStatus(status);
    if (chatMsg != null &&
        req.sessionId != null &&
        req.sessionId!.isNotEmpty) {
      await SessionRepository.instance.saveMessageIfNew(
        uid: req.customerUid,
        sessionId: req.sessionId!,
        role: 'agent',
        text: chatMsg,
      );
    }
  }

  Future<void> decline(String requestId) async {
    await updateStatus(requestId, 'DECLINED');
  }

  DateTime? _parseScheduledTime(String timeText) {
    final now = DateTime.now();
    final lower = timeText.toLowerCase();
    if (lower.contains('kal') || lower.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1, 10, 0);
    }
    if (lower.contains('subah') || lower.contains('morning')) {
      return DateTime(now.year, now.month, now.day,
          now.hour < 10 ? 10 : now.hour + 2, 0);
    }
    if (lower.contains('sham') || lower.contains('evening')) {
      return DateTime(now.year, now.month, now.day, 18, 0);
    }
    final match = RegExp(r'(\d{1,2})').firstMatch(lower);
    if (match != null) {
      final h = int.tryParse(match.group(1)!) ?? 10;
      return DateTime(now.year, now.month, now.day, h.clamp(8, 20), 0);
    }
    return now.add(const Duration(hours: 2));
  }
}
