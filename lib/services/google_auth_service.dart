import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Web OAuth client (client_type 3) from android/app/google-services.json.
/// Required on Android so Firebase Auth receives a valid idToken.
const kGoogleWebClientId =
    '74111648461-5ir9i1cqa7188de732llqmfdmtde1v59.apps.googleusercontent.com';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kGoogleWebClientId,
    scopes: const ['email', 'profile'],
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  Future<UserCredential> signInWithGoogle() async {
    try {
      return await _signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' &&
          (e.message?.contains('10') ?? false)) {
        throw StateError(
          'Google Sign-In is not configured for this APK. In Firebase Console, '
          'add SHA-1 and SHA-256 for package com.example.ustaad_ai_app, '
          'download a new google-services.json, rebuild the APK, and reinstall.',
        );
      }
      rethrow;
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw GoogleSignInCanceledException();
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null && accessToken == null) {
      throw StateError(
        'Google Sign-In returned no tokens. Add your release SHA-1/SHA-256 '
        'in Firebase Console → Project settings → Your apps.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([
      FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class GoogleSignInCanceledException implements Exception {
  @override
  String toString() => 'Google sign-in was canceled';
}
