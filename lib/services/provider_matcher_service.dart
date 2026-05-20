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
      availableSlots: ['9am-1pm', '2pm-5pm'],
      availableDays: ['Mon-Sat'],
      ratingCount: 24,
    ),
    LabourProvider(
      id: 'p9',
      name: 'Imran Plumbing Co.',
      service: 'Plumber',
      rating: 4.5,
      distanceKm: 3.3,
      basePrice: 1600,
      availableSlots: ['10am-4pm'],
      availableDays: ['Mon-Fri'],
      ratingCount: 18,
    ),
    LabourProvider(
      id: 'p11',
      name: 'Nadeem Pipe Fix',
      service: 'Plumber',
      rating: 4.4,
      distanceKm: 2.5,
      basePrice: 1400,
      availableSlots: ['8am-12pm', '3pm-7pm'],
      availableDays: ['Mon-Sun'],
      ratingCount: 12,
    ),
    LabourProvider(
      id: 'p2',
      name: 'Kamran AC Services',
      service: 'AC Technician',
      rating: 4.8,
      distanceKm: 2.1,
      basePrice: 2500,
      availableSlots: ['10am-6pm'],
      availableDays: ['Mon-Fri'],
      ratingCount: 30,
    ),
    LabourProvider(
      id: 'p3',
      name: 'Ali Electric Works',
      service: 'Electrician',
      rating: 4.7,
      distanceKm: 0.8,
      basePrice: 1500,
      availableSlots: ['9am-3pm', '5pm-8pm'],
      availableDays: ['Mon-Sat'],
      ratingCount: 22,
    ),
    LabourProvider(
      id: 'p10',
      name: 'Zain Electric',
      service: 'Electrician',
      rating: 4.6,
      distanceKm: 2.0,
      basePrice: 1400,
      availableSlots: ['11am-7pm'],
      availableDays: ['Tue-Sat'],
      ratingCount: 15,
    ),
    LabourProvider(
      id: 'p4',
      name: 'Sana Beauty Studio',
      service: 'Beautician',
      rating: 4.95,
      distanceKm: 3.0,
      basePrice: 3500,
      availableSlots: ['10am-8pm'],
      availableDays: ['Mon-Sun'],
      ratingCount: 40,
    ),
    LabourProvider(
      id: 'p5',
      name: 'Hassan Carpentry',
      service: 'Carpenter',
      rating: 4.6,
      distanceKm: 4.2,
      basePrice: 2000,
      availableSlots: ['8am-5pm'],
      availableDays: ['Mon-Fri'],
      ratingCount: 10,
    ),
  ];

  /// Check if the customer's requested time falls within any of the provider's
  /// available time intervals and day ranges.
  bool timeMatchesSlots(String? customerTime, List<String> slots, List<String> days) {
    if (customerTime == null || customerTime.trim().isEmpty) return true;
    if (slots.isEmpty) return true;

    final t = customerTime.toLowerCase();

    // Check day match
    if (days.isNotEmpty) {
      final requestedDay = _extractDayFromText(t);
      if (requestedDay != null) {
        final dayNumbers = _parseDayRanges(days);
        if (dayNumbers.isNotEmpty && !dayNumbers.contains(requestedDay)) {
          return false;
        }
      }
    }

    // Check time interval match
    final requestedHour = _extractHourFromText(t);
    if (requestedHour == null) return true; // Can't parse time, assume match

    for (final slot in slots) {
      final interval = _parseInterval(slot);
      if (interval != null) {
        final (start, end) = interval;
        if (requestedHour >= start && requestedHour < end) return true;
      }
    }
    return false;
  }

  /// Extract an hour (0-23) from free-form customer text.
  int? _extractHourFromText(String lower) {
    // Direct hour mentions: "10am", "2pm", "9 am"
    final hourMatch = RegExp(r'(\d{1,2})\s*(am|pm|baje|bje)').firstMatch(lower);
    if (hourMatch != null) {
      var h = int.tryParse(hourMatch.group(1)!) ?? 0;
      final suffix = hourMatch.group(2);
      if (suffix == 'pm' && h != 12) h += 12;
      if (suffix == 'am' && h == 12) h = 0;
      return h.clamp(0, 23);
    }

    // Time words
    if (lower.contains('subah') || lower.contains('morning')) return 9;
    if (lower.contains('dopahar') || lower.contains('afternoon')) return 14;
    if (lower.contains('sham') || lower.contains('evening')) return 17;
    if (lower.contains('raat') || lower.contains('night')) return 20;

    // Just a bare number
    final numMatch = RegExp(r'(\d{1,2})').firstMatch(lower);
    if (numMatch != null) {
      final h = int.tryParse(numMatch.group(1)!) ?? 0;
      return h.clamp(1, 23);
    }
    return null;
  }

  /// Extract a weekday number (1=Mon..7=Sun) from customer text.
  int? _extractDayFromText(String lower) {
    // Day-of-week names
    const dayMap = {
      'monday': 1, 'mon': 1,
      'tuesday': 2, 'tue': 2,
      'wednesday': 3, 'wed': 3,
      'thursday': 4, 'thu': 4,
      'friday': 5, 'fri': 5,
      'saturday': 6, 'sat': 6,
      'sunday': 7, 'sun': 7,
      // Urdu/Roman Urdu
      'pir': 1, 'somwar': 1,
      'mangal': 2,
      'budh': 3,
      'jumeraat': 4,
      'juma': 5,
      'hafta': 6, 'sanichar': 6,
      'itwar': 7,
    };

    for (final entry in dayMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    // "today" / "aaj" → current weekday
    if (lower.contains('today') || lower.contains('aaj')) {
      return DateTime.now().weekday;
    }
    // "tomorrow" / "kal" → next weekday
    if (lower.contains('tomorrow') || lower.contains('kal')) {
      return DateTime.now().add(const Duration(days: 1)).weekday;
    }
    return null;
  }

  /// Parse "9am-1pm" → (9, 13)
  (int, int)? _parseInterval(String slot) {
    final trimmed = slot.trim().toLowerCase();
    final dash = trimmed.indexOf('-');
    if (dash < 0) return null;
    final startStr = trimmed.substring(0, dash).trim();
    final endStr = trimmed.substring(dash + 1).trim();
    final start = _parseHour(startStr);
    final end = _parseHour(endStr);
    if (start == null || end == null) return null;
    return (start, end);
  }

  int? _parseHour(String s) {
    final match = RegExp(r'^(\d{1,2})\s*(am|pm)?$').firstMatch(s.trim());
    if (match == null) return null;
    var h = int.tryParse(match.group(1)!);
    if (h == null) return null;
    final ampm = match.group(2);
    if (ampm == 'pm' && h != 12) h += 12;
    if (ampm == 'am' && h == 12) h = 0;
    return h.clamp(0, 23);
  }

  /// Parse day ranges like ["Mon-Fri", "Sun"] into a set of weekday numbers.
  Set<int> _parseDayRanges(List<String> dayRanges) {
    final days = <int>{};
    for (final part in dayRanges) {
      final trimmed = part.trim();
      final dash = trimmed.indexOf('-');
      if (dash < 0) {
        final d = _dayToNumber(trimmed);
        if (d != null) days.add(d);
      } else {
        final start = _dayToNumber(trimmed.substring(0, dash).trim());
        final end = _dayToNumber(trimmed.substring(dash + 1).trim());
        if (start != null && end != null) {
          if (start <= end) {
            for (var i = start; i <= end; i++) days.add(i);
          } else {
            for (var i = start; i <= 7; i++) days.add(i);
            for (var i = 1; i <= end; i++) days.add(i);
          }
        }
      }
    }
    return days;
  }

  int? _dayToNumber(String s) {
    switch (s.toLowerCase().trim()) {
      case 'mon': case 'monday': return 1;
      case 'tue': case 'tuesday': return 2;
      case 'wed': case 'wednesday': return 3;
      case 'thu': case 'thursday': return 4;
      case 'fri': case 'friday': return 5;
      case 'sat': case 'saturday': return 6;
      case 'sun': case 'sunday': return 7;
      default: return null;
    }
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
            timeMatchesSlots(intent.time, p.availableSlots, p.availableDays))
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
    return 'Recommended: ${p.name} — ⭐ ${p.rating.toStringAsFixed(1)} • ${p.distanceKm}km • ~${p.priceEstimatePkr} PKR\n'
        'Schedule: ${p.scheduleDisplay}';
  }
}
