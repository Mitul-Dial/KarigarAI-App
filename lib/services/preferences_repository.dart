import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_settings.dart';
import '../models/user_role.dart';

class PreferencesRepository {
  PreferencesRepository._();
  static final PreferencesRepository instance = PreferencesRepository._();

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _roleDoc(String uid, UserRole role) =>
      _user(uid).collection('profiles').doc(role.code);

  Future<bool> isOnboardingComplete(String uid) async {
    final snap = await _user(uid).get();
    return snap.data()?['onboardingComplete'] == true;
  }

  Future<void> completeOnboarding({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _user(uid).set({
      'onboardingComplete': true,
      'phone': phone,
      'displayName': name,
    }, SetOptions(merge: true));
    final base = RoleSettings(displayName: name, phone: phone);
    await _roleDoc(uid, UserRole.customer).set(base.toMap(), SetOptions(merge: true));
    await _roleDoc(uid, UserRole.provider).set(
      base.copyWith(providerServiceType: 'Plumber').toMap(),
      SetOptions(merge: true),
    );
  }

  Future<RoleSettings> loadRole(String uid, UserRole role) async {
    final snap = await _roleDoc(uid, role).get();
    if (snap.exists) return RoleSettings.fromMap(snap.data());
    final userSnap = await _user(uid).get();
    final u = userSnap.data();
    return RoleSettings(
      displayName: u?['displayName'] as String? ?? '',
      phone: u?['phone'] as String? ?? '',
    );
  }

  Future<void> saveRole(String uid, UserRole role, RoleSettings settings) async {
    await _roleDoc(uid, role).set(settings.toMap(), SetOptions(merge: true));
  }
}
