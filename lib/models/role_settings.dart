import 'user_preferences.dart';

/// Settings stored per role under users/{uid}/profiles/{customer|provider}.
class RoleSettings {
  const RoleSettings({
    this.displayName = '',
    this.phone = '',
    this.defaultLocation = '',
    this.language = AppLanguage.romanUrdu,
    this.photoUrl = '',
    this.age,
    this.dateOfBirth = '',
    this.providerServiceType = 'Plumber',
    this.availableSlots = '9am-6pm',
    this.availableDays = 'Mon-Fri',
    this.isProviderOnline = false,
  });

  final String displayName;
  final String phone;
  final String defaultLocation;
  final AppLanguage language;
  final String photoUrl;
  final int? age;
  final String dateOfBirth;
  final String providerServiceType;

  /// Time intervals in format: "9am-1pm, 3pm-6pm"
  final String availableSlots;

  /// Day ranges in format: "Mon-Fri" or "Mon-Wed, Fri-Sat"
  final String availableDays;

  final bool isProviderOnline;

  /// Parses time intervals into a list of (startHour, endHour) pairs.
  /// E.g. "9am-1pm, 3pm-6pm" → [(9, 13), (15, 18)]
  List<(int, int)> get timeIntervals {
    final intervals = <(int, int)>[];
    for (final part in availableSlots.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final dash = trimmed.indexOf('-');
      if (dash < 0) continue;
      final startStr = trimmed.substring(0, dash).trim();
      final endStr = trimmed.substring(dash + 1).trim();
      final start = _parseHour(startStr);
      final end = _parseHour(endStr);
      if (start != null && end != null) {
        intervals.add((start, end));
      }
    }
    return intervals;
  }

  /// Parses day ranges into a set of weekday numbers (1=Mon, 7=Sun).
  /// E.g. "Mon-Fri" → {1,2,3,4,5}; "Mon-Wed, Fri-Sat" → {1,2,3,5,6}
  Set<int> get dayNumbers {
    final days = <int>{};
    for (final part in availableDays.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final dash = trimmed.indexOf('-');
      if (dash < 0) {
        final d = _dayToNumber(trimmed);
        if (d != null) days.add(d);
      } else {
        final startStr = trimmed.substring(0, dash).trim();
        final endStr = trimmed.substring(dash + 1).trim();
        final start = _dayToNumber(startStr);
        final end = _dayToNumber(endStr);
        if (start != null && end != null) {
          if (start <= end) {
            for (var i = start; i <= end; i++) {
              days.add(i);
            }
          } else {
            // Wrap around: e.g. Fri-Mon → 5,6,7,1
            for (var i = start; i <= 7; i++) {
              days.add(i);
            }
            for (var i = 1; i <= end; i++) {
              days.add(i);
            }
          }
        }
      }
    }
    return days;
  }

  /// Legacy getter for backward compatibility
  List<String> get slotList {
    final result = <String>[];
    final days = dayNumbers;
    final intervals = timeIntervals;
    for (final dayNum in days) {
      final dayName = _numberToDay(dayNum);
      for (final (start, end) in intervals) {
        result.add('$dayName ${_formatHour(start)}-${_formatHour(end)}');
      }
    }
    return result.isEmpty ? [availableSlots] : result;
  }

  RoleSettings copyWith({
    String? displayName,
    String? phone,
    String? defaultLocation,
    AppLanguage? language,
    String? photoUrl,
    int? age,
    String? dateOfBirth,
    String? providerServiceType,
    String? availableSlots,
    String? availableDays,
    bool? isProviderOnline,
  }) {
    return RoleSettings(
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      language: language ?? this.language,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      providerServiceType: providerServiceType ?? this.providerServiceType,
      availableSlots: availableSlots ?? this.availableSlots,
      availableDays: availableDays ?? this.availableDays,
      isProviderOnline: isProviderOnline ?? this.isProviderOnline,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'phone': phone,
        'defaultLocation': defaultLocation,
        'language': language.code,
        'photoUrl': photoUrl,
        if (age != null) 'age': age,
        'dateOfBirth': dateOfBirth,
        'providerServiceType': providerServiceType,
        'availableSlots': availableSlots,
        'availableDays': availableDays,
        'isProviderOnline': isProviderOnline,
      };

  factory RoleSettings.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const RoleSettings();
    return RoleSettings(
      displayName: data['displayName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      defaultLocation: data['defaultLocation'] as String? ?? '',
      language: appLanguageFromCode(data['language'] as String?),
      photoUrl: data['photoUrl'] as String? ?? '',
      age: (data['age'] as num?)?.toInt(),
      dateOfBirth: data['dateOfBirth'] as String? ?? '',
      providerServiceType: data['providerServiceType'] as String? ?? 'Plumber',
      availableSlots: data['availableSlots'] as String? ?? '9am-6pm',
      availableDays: data['availableDays'] as String? ?? 'Mon-Fri',
      isProviderOnline: data['isProviderOnline'] as bool? ?? false,
    );
  }

  UserPreferences toLegacyPrefs() => UserPreferences(
        language: language,
        defaultLocation: defaultLocation,
        displayName: displayName,
        providerServiceType: providerServiceType,
        isProviderOnline: isProviderOnline,
      );

  // ─── Helpers ───────────────────────────────────────────────────────

  static int? _parseHour(String s) {
    final lower = s.toLowerCase().trim();
    final match = RegExp(r'^(\d{1,2})\s*(am|pm)?$').firstMatch(lower);
    if (match == null) return null;
    var hour = int.tryParse(match.group(1)!);
    if (hour == null) return null;
    final ampm = match.group(2);
    if (ampm == 'pm' && hour != 12) hour += 12;
    if (ampm == 'am' && hour == 12) hour = 0;
    return hour.clamp(0, 23);
  }

  static int? _dayToNumber(String s) {
    switch (s.toLowerCase().trim()) {
      case 'mon':
      case 'monday':
        return 1;
      case 'tue':
      case 'tuesday':
        return 2;
      case 'wed':
      case 'wednesday':
        return 3;
      case 'thu':
      case 'thursday':
        return 4;
      case 'fri':
      case 'friday':
        return 5;
      case 'sat':
      case 'saturday':
        return 6;
      case 'sun':
      case 'sunday':
        return 7;
      default:
        return null;
    }
  }

  static String _numberToDay(int n) {
    switch (n) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '?';
    }
  }

  static String _formatHour(int h) {
    if (h == 0) return '12am';
    if (h < 12) return '${h}am';
    if (h == 12) return '12pm';
    return '${h - 12}pm';
  }
}
