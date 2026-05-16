enum AppLanguage { english, urdu, romanUrdu }

extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.urdu:
        return 'Urdu';
      case AppLanguage.romanUrdu:
        return 'Roman Urdu';
    }
  }

  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.urdu:
        return 'Urdu';
      case AppLanguage.romanUrdu:
        return 'Roman Urdu';
    }
  }

  bool get isRtl => this == AppLanguage.urdu;
}

AppLanguage appLanguageFromCode(String? value) {
  switch (value) {
    case 'Urdu':
      return AppLanguage.urdu;
    case 'English':
      return AppLanguage.english;
    case 'Roman Urdu':
      return AppLanguage.romanUrdu;
    default:
      return AppLanguage.romanUrdu;
  }
}

class UserPreferences {
  const UserPreferences({
    this.language = AppLanguage.romanUrdu,
    this.defaultLocation = '',
    this.displayName = '',
    this.providerServiceType = 'Plumber',
    this.isProviderOnline = false,
  });

  final AppLanguage language;
  final String defaultLocation;
  final String displayName;
  final String providerServiceType;
  final bool isProviderOnline;

  UserPreferences copyWith({
    AppLanguage? language,
    String? defaultLocation,
    String? displayName,
    String? providerServiceType,
    bool? isProviderOnline,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      displayName: displayName ?? this.displayName,
      providerServiceType: providerServiceType ?? this.providerServiceType,
      isProviderOnline: isProviderOnline ?? this.isProviderOnline,
    );
  }

  Map<String, dynamic> toMap() => {
        'language': language.code,
        'defaultLocation': defaultLocation,
        'displayName': displayName,
        'providerServiceType': providerServiceType,
        'isProviderOnline': isProviderOnline,
      };

  factory UserPreferences.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const UserPreferences();
    return UserPreferences(
      language: appLanguageFromCode(data['language'] as String?),
      defaultLocation: data['defaultLocation'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      providerServiceType: data['providerServiceType'] as String? ?? 'Plumber',
      isProviderOnline: data['isProviderOnline'] as bool? ?? false,
    );
  }
}
