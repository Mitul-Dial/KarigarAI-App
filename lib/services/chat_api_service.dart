import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user_preferences.dart';

class ChatApiResponse {
  ChatApiResponse({
    required this.text,
    this.type,
    this.explanation,
    this.provider,
  });

  final String text;
  final String? type;
  final String? explanation;
  final Map<String, dynamic>? provider;

  factory ChatApiResponse.fromJson(Map<String, dynamic> data) {
    return ChatApiResponse(
      text: data['text'] as String? ?? 'Sorry, I encountered an error.',
      type: data['type'] as String?,
      explanation: data['explanation'] as String?,
      provider: data['provider'] is Map
          ? Map<String, dynamic>.from(data['provider'] as Map)
          : null,
    );
  }
}

class IntentApiResponse {
  IntentApiResponse({
    this.service,
    this.location,
    this.time,
    this.clarificationNeeded = false,
    this.clarificationMessage,
    this.confidence,
  });

  final String? service;
  final String? location;
  final String? time;
  final bool clarificationNeeded;
  final String? clarificationMessage;
  final double? confidence;

  factory IntentApiResponse.fromJson(Map<String, dynamic> data) {
    return IntentApiResponse(
      service: data['service'] as String?,
      location: data['location'] as String?,
      time: data['time'] as String?,
      clarificationNeeded: data['clarification_needed'] as bool? ?? false,
      clarificationMessage: data['clarification_message'] as String?,
      confidence: (data['confidence'] as num?)?.toDouble(),
    );
  }
}

class ChatApiService {
  ChatApiService._();
  static final ChatApiService instance = ChatApiService._();

  /// Server-side Gemini intent parse (uses Vercel backend fixes).
  Future<IntentApiResponse> parseIntent({
    required String message,
    String? history,
    String? defaultLocation,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/intent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        if (history != null && history.trim().isNotEmpty) 'history': history.trim(),
        if (defaultLocation != null && defaultLocation.trim().isNotEmpty)
          'defaultLocation': defaultLocation.trim(),
      }),
    );

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        detail = err['error']?.toString() ?? detail;
      } catch (_) {}
      throw HttpException(
        'Intent API ${response.statusCode}: $detail',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return IntentApiResponse.fromJson(data);
  }

  Future<ChatApiResponse> send({
    required String message,
    String? uid,
    UserPreferences? prefs,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/api/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        if (uid != null) 'uid': uid,
        if (prefs != null) ...{
          'language': prefs.language.code,
          if (prefs.defaultLocation.isNotEmpty)
            'location': prefs.defaultLocation,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Server returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatApiResponse.fromJson(data);
  }
}

class HttpException implements Exception {
  HttpException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
