import 'supabase_secrets.dart';

class SupabaseConfig {
  static const String url = SupabaseSecrets.url;
  static const String anonKey = SupabaseSecrets.anonKey;
  static const String bucket = SupabaseSecrets.avatarsBucket;

  static bool get isConfigured =>
      url.startsWith('https://') &&
      !url.contains('YOUR_PROJECT') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('YOUR_SUPABASE');
}
