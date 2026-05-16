class LabourProvider {
  LabourProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.rating,
    required this.distanceKm,
    required this.basePrice,
    this.availableSlots = const [],
  });

  final String id;
  final String name;
  final String service;
  final double rating;
  final double distanceKm;
  final int basePrice;
  final List<String> availableSlots;

  int get priceEstimatePkr => basePrice;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'service': service,
        'rating': rating,
        'distanceKm': distanceKm,
        'basePrice': basePrice,
        'priceEstimatePkr': priceEstimatePkr,
        'availableSlots': availableSlots,
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
    );
  }
}
