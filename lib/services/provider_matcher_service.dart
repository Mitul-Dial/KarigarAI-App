import '../models/labour_provider.dart';
import '../models/service_intent.dart';

class ProviderMatcherService {
  ProviderMatcherService._();
  static final ProviderMatcherService instance = ProviderMatcherService._();

  static final List<LabourProvider> _catalog = [
    LabourProvider(
      id: 'p1',
      name: 'Rashid Plumbing',
      service: 'Plumber',
      rating: 4.9,
      distanceKm: 1.2,
      basePrice: 1800,
      availableSlots: ['Today 9 AM', 'Today 2 PM', 'Tomorrow 10 AM'],
    ),
    LabourProvider(
      id: 'p9',
      name: 'Imran Plumbing Co.',
      service: 'Plumber',
      rating: 4.5,
      distanceKm: 3.3,
      basePrice: 1600,
      availableSlots: ['Today 11 AM', 'Tomorrow 9 AM'],
    ),
    LabourProvider(
      id: 'p11',
      name: 'Nadeem Pipe Fix',
      service: 'Plumber',
      rating: 4.4,
      distanceKm: 2.5,
      basePrice: 1400,
      availableSlots: ['Tomorrow 10 AM', 'Tomorrow 2 PM'],
    ),
    LabourProvider(
      id: 'p2',
      name: 'Kamran AC Services',
      service: 'AC Technician',
      rating: 4.8,
      distanceKm: 2.1,
      basePrice: 2500,
      availableSlots: ['Today 4 PM', 'Tomorrow 10 AM'],
    ),
    LabourProvider(
      id: 'p3',
      name: 'Ali Electric Works',
      service: 'Electrician',
      rating: 4.7,
      distanceKm: 0.8,
      basePrice: 1500,
      availableSlots: ['Today 9 AM', 'Today 3 PM', 'Tomorrow 9 AM'],
    ),
    LabourProvider(
      id: 'p10',
      name: 'Zain Electric',
      service: 'Electrician',
      rating: 4.6,
      distanceKm: 2.0,
      basePrice: 1400,
      availableSlots: ['Today 2 PM', 'Tomorrow 11 AM'],
    ),
    LabourProvider(
      id: 'p4',
      name: 'Sana Beauty Studio',
      service: 'Beautician',
      rating: 4.95,
      distanceKm: 3.0,
      basePrice: 3500,
      availableSlots: ['Today 6 PM', 'Tomorrow 10 AM'],
    ),
    LabourProvider(
      id: 'p5',
      name: 'Hassan Carpentry',
      service: 'Carpenter',
      rating: 4.6,
      distanceKm: 4.2,
      basePrice: 2000,
      availableSlots: ['Tomorrow 10 AM'],
    ),
  ];

  bool timeMatchesSlots(String? customerTime, List<String> slots) {
    if (customerTime == null || customerTime.trim().isEmpty) return true;
    if (slots.isEmpty) return true;
    final t = customerTime.toLowerCase();
    for (final slot in slots) {
      final s = slot.toLowerCase();
      if (_overlapTime(t, s)) return true;
    }
    return false;
  }

  bool _overlapTime(String customer, String slot) {
    final hasMorning = customer.contains('subah') || customer.contains('morning') || customer.contains('9') || customer.contains('10') || customer.contains('11');
    final hasEvening = customer.contains('sham') || customer.contains('evening') || customer.contains('4') || customer.contains('5') || customer.contains('6');
    final hasTomorrow = customer.contains('kal') || customer.contains('tomorrow');
    final hasToday = customer.contains('aaj') || customer.contains('today') || !hasTomorrow;

    if (slot.contains('tomorrow') && !hasTomorrow && hasToday) return false;
    if (slot.contains('today') && hasTomorrow && !hasToday) return false;

    if (hasMorning && (slot.contains('9') || slot.contains('10') || slot.contains('11') || slot.contains('am'))) {
      return true;
    }
    if (hasEvening && (slot.contains('2') || slot.contains('3') || slot.contains('4') || slot.contains('5') || slot.contains('6') || slot.contains('pm'))) {
      return true;
    }
    if (RegExp(r'\d').hasMatch(customer) && RegExp(r'\d').hasMatch(slot)) {
      return true;
    }
    return slot.contains('today') || slot.contains('tomorrow');
  }

  List<LabourProvider> rankForIntent(
    ServiceIntent intent, {
    List<String> rejectedIds = const [],
  }) {
    final service = intent.service?.trim() ?? '';
    if (service.isEmpty) return [];

    return _catalog
        .where((p) =>
            !rejectedIds.contains(p.id) &&
            p.service.toLowerCase() == service.toLowerCase() &&
            timeMatchesSlots(intent.time, p.availableSlots))
        .toList()
      ..sort((a, b) {
        final scoreA = a.rating * 10 - a.distanceKm * 2;
        final scoreB = b.rating * 10 - b.distanceKm * 2;
        return scoreB.compareTo(scoreA);
      });
  }

  LabourProvider? nextProvider(
    ServiceIntent intent, {
    List<String> rejectedIds = const [],
  }) {
    final list = rankForIntent(intent, rejectedIds: rejectedIds);
    return list.isEmpty ? null : list.first;
  }

  String noProviderMessage(String service) {
    return 'No $service available for your requested time. Please try a different time or service.';
  }

  String matchExplanation(LabourProvider p) {
    final slots = p.availableSlots.isNotEmpty ? p.availableSlots.join(', ') : 'Flexible';
    return 'Recommended: ${p.name} — ⭐ ${p.rating} • ${p.distanceKm}km • ~${p.priceEstimatePkr} PKR\nAvailable: $slots';
  }
}
