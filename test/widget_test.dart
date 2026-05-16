import 'package:flutter_test/flutter_test.dart';
import 'package:ustaad_ai_app/models/service_intent.dart';
import 'package:ustaad_ai_app/services/intent_parser_service.dart';

void main() {
  test('intent merges service location time', () {
    final a = IntentParserService.instance.parseMessage('Mujhe plumber chahiye');
    final b = IntentParserService.instance.parseMessage('F-8 Islamabad kal subah 10 baje');
    final merged = a.merge(b);
    expect(merged.service, 'Plumber');
    expect(merged.isComplete, true);
  });
}
