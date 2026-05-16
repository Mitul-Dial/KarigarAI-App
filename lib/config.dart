class AppConfig {
  /// Backend base URL (Haazir Next.js on Vercel).
  /// After deploying https://github.com/muxby/Haazir, set this to your Vercel URL.
  /// Override locally: flutter run --dart-define=API_BASE_URL=https://your-app.vercel.app
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://karigar-ai-nu.vercel.app',
  );
}
