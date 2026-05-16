import 'user_preferences.dart';
import 'user_role.dart';

class UserProfile {
  const UserProfile({
    this.role,
    this.preferences = const UserPreferences(),
    this.providerServiceType = 'Plumber',
    this.isProviderOnline = false,
  });

  final UserRole? role;
  final UserPreferences preferences;
  final String providerServiceType;
  final bool isProviderOnline;

  Map<String, dynamic> toMap() => {
        if (role != null) 'role': role!.code,
        ...preferences.toMap(),
        'providerServiceType': providerServiceType,
        'isProviderOnline': isProviderOnline,
      };

  factory UserProfile.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const UserProfile();
    return UserProfile(
      role: UserRoleCode.fromCode(data['role'] as String?),
      preferences: UserPreferences.fromMap(data),
      providerServiceType: data['providerServiceType'] as String? ?? 'Plumber',
      isProviderOnline: data['isProviderOnline'] as bool? ?? false,
    );
  }

  UserProfile copyWith({
    UserRole? role,
    UserPreferences? preferences,
    String? providerServiceType,
    bool? isProviderOnline,
  }) {
    return UserProfile(
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      providerServiceType: providerServiceType ?? this.providerServiceType,
      isProviderOnline: isProviderOnline ?? this.isProviderOnline,
    );
  }
}
