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
    this.availableSlots = 'Today 9 AM, Today 2 PM, Tomorrow 10 AM',
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
  final String availableSlots;
  final bool isProviderOnline;

  List<String> get slotList => availableSlots
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

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
      availableSlots: data['availableSlots'] as String? ??
          'Today 9 AM, Today 2 PM, Tomorrow 10 AM',
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
}
