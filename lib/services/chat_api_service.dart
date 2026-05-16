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

class ChatApiService {
  ChatApiService._();
  static final ChatApiService instance = ChatApiService._();

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
