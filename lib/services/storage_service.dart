import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Uploads 64×64 JPEG to Supabase Storage. Path: profiles/{uid}/{role}.jpg
  Future<String> uploadProfilePhoto(Uint8List jpegBytes, String roleCode) async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured. Copy supabase_secrets.example.dart to supabase_secrets.dart and add your URL + anon key.',
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final path = 'profiles/$uid/$roleCode.jpg';
    final bucket = Supabase.instance.client.storage.from(SupabaseConfig.bucket);

    await bucket.uploadBinary(
      path,
      jpegBytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );

    return bucket.getPublicUrl(path);
  }
}
