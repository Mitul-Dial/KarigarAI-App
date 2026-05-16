import 'labour_provider.dart';

class ServiceRequest {
  ServiceRequest({
    required this.id,
    required this.customerUid,
    required this.service,
    required this.time,
    required this.location,
    required this.price,
    required this.status,
    this.providerUid,
    this.providerName,
    this.customerName,
    this.providerSnapshot,
    this.scheduledAt,
    this.rating,
    this.feedback,
    this.createdAt,
    this.sessionId,
  });

  final String id;
  final String customerUid;
  final String? providerUid;
  final String service;
  final String time;
  final String location;
  final String price;
  final String status;
  final String? providerName;
  final String? customerName;
  final Map<String, dynamic>? providerSnapshot;
  final DateTime? scheduledAt;
  final int? rating;
  final String? feedback;
  final DateTime? createdAt;
  final String? sessionId;

  Map<String, dynamic> toMap() => {
        'customerUid': customerUid,
        if (providerUid != null) 'providerUid': providerUid,
        'service': service,
        'time': time,
        'location': location,
        'price': price,
        'status': status,
        if (providerName != null) 'providerName': providerName,
        if (customerName != null) 'customerName': customerName,
        if (providerSnapshot != null) 'providerSnapshot': providerSnapshot,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        'createdAt': createdAt ?? DateTime.now(),
        if (sessionId != null) 'sessionId': sessionId,
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      };

  factory ServiceRequest.fromMap(String id, Map<String, dynamic> data) {
    DateTime? scheduled;
    final raw = data['scheduledAt'];
    if (raw != null) {
      scheduled = raw is DateTime ? raw : (raw as dynamic).toDate();
    }
    return ServiceRequest(
      id: id,
      customerUid: data['customerUid'] as String? ?? '',
      providerUid: data['providerUid'] as String?,
      service: data['service'] as String? ?? 'Service',
      time: data['time'] as String? ?? '',
      location: data['location'] as String? ?? '',
      price: data['price'] as String? ?? '',
      status: data['status'] as String? ?? 'PENDING',
      providerName: data['providerName'] as String?,
      customerName: data['customerName'] as String?,
      providerSnapshot: data['providerSnapshot'] as Map<String, dynamic>?,
      scheduledAt: scheduled,
      rating: (data['rating'] as num?)?.toInt(),
      feedback: data['feedback'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      sessionId: data['sessionId'] as String?,
    );
  }

  LabourProvider? get provider =>
      providerSnapshot != null ? LabourProvider.fromMap(providerSnapshot!) : null;

  ServiceRequest copyWith({
    String? status,
    String? providerUid,
    String? providerName,
    int? rating,
    String? feedback,
  }) {
    return ServiceRequest(
      id: id,
      customerUid: customerUid,
      providerUid: providerUid ?? this.providerUid,
      service: service,
      time: time,
      location: location,
      price: price,
      status: status ?? this.status,
      providerName: providerName ?? this.providerName,
      customerName: customerName,
      providerSnapshot: providerSnapshot,
      scheduledAt: scheduledAt,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt,
      sessionId: sessionId,
    );
  }
}
