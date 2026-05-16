import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';

class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  Future<UserProfile> load(String uid) async {
    final snap = await _doc(uid).get();
    return UserProfile.fromMap(snap.data());
  }

  Stream<UserProfile> watch(String uid) {
    return _doc(uid).snapshots().map((s) => UserProfile.fromMap(s.data()));
  }

  Future<void> save(String uid, UserProfile profile) async {
    await _doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> setRole(String uid, UserRole role) async {
    await _doc(uid).set({'role': role.code}, SetOptions(merge: true));
  }
}
