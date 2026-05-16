/// Accumulated booking context — each new message adds missing fields only.
class ServiceIntent {
  const ServiceIntent({
    this.service,
    this.location,
    this.time,
  });

  final String? service;
  final String? location;
  final String? time;

  bool get isComplete =>
      _filled(service) && _filled(location) && _filled(time);

  bool _filled(String? v) => v != null && v.trim().isNotEmpty;

  String? get nextMissingField {
    if (!_filled(service)) return 'service';
    if (!_filled(location)) return 'location';
    if (!_filled(time)) return 'time';
    return null;
  }

  /// Merge: new service replaces; location/time append only when adding detail.
  ServiceIntent merge(ServiceIntent other) {
    return ServiceIntent(
      service: other.service != null && other.service!.trim().isNotEmpty
          ? other.service!.trim()
          : service,
      location: _mergeText(location, other.location),
      time: _mergeText(time, other.time),
    );
  }

  String? _mergeText(String? existing, String? incoming) {
    if (incoming == null || incoming.trim().isEmpty) return existing;
    final inc = incoming.trim();
    if (existing == null || existing.trim().isEmpty) return inc;
    final ex = existing.trim();
    if (ex.toLowerCase() == inc.toLowerCase()) return ex;
    if (ex.toLowerCase().contains(inc.toLowerCase())) return ex;
    if (inc.toLowerCase().contains(ex.toLowerCase())) return inc;
    return '$ex, $inc';
  }

  Map<String, dynamic> toMap() => {
        if (service != null) 'service': service,
        if (location != null) 'location': location,
        if (time != null) 'time': time,
      };

  factory ServiceIntent.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const ServiceIntent();
    return ServiceIntent(
      service: data['service'] as String?,
      location: data['location'] as String?,
      time: data['time'] as String?,
    );
  }

  String summary() {
    final parts = <String>[];
    if (service != null) parts.add('Service: $service');
    if (location != null) parts.add('Location: $location');
    if (time != null) parts.add('Time: $time');
    return parts.join(' • ');
  }
}
