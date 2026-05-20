class LabourProvider {
  LabourProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.rating,
    required this.distanceKm,
    required this.basePrice,
    this.availableSlots = const [],
    this.availableDays = const [],
    this.ratingCount = 0,
  });

  final String id;
  final String name;
  final String service;
  final double rating;
  final double distanceKm;
  final int basePrice;
  /// Time intervals like ["9am-1pm", "3pm-6pm"]
  final List<String> availableSlots;
  /// Day ranges like ["Mon-Fri"] or ["Mon-Wed", "Sat"]
  final List<String> availableDays;
  /// How many ratings have been submitted (for weighted average calculation)
  final int ratingCount;

  int get priceEstimatePkr => basePrice;

  /// Human-readable schedule string
  String get scheduleDisplay {
    final days = availableDays.isNotEmpty ? availableDays.join(', ') : 'All days';
    final slots = availableSlots.isNotEmpty ? availableSlots.join(', ') : 'Flexible';
    return '$days • $slots';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'service': service,
        'rating': rating,
        'distanceKm': distanceKm,
        'basePrice': basePrice,
        'priceEstimatePkr': priceEstimatePkr,
        'availableSlots': availableSlots,
        'availableDays': availableDays,
        'ratingCount': ratingCount,
      };

  factory LabourProvider.fromMap(Map<String, dynamic> data) {
    return LabourProvider(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Provider',
      service: data['service'] as String? ?? 'Service',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.5,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 2.0,
      basePrice: (data['basePrice'] as num?)?.toInt() ??
          (data['priceEstimatePkr'] as num?)?.toInt() ??
          1500,
      availableSlots: (data['availableSlots'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      availableDays: (data['availableDays'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
