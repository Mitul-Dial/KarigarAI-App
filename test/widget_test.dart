import 'package:flutter_test/flutter_test.dart';
import 'package:ustaad_ai_app/models/service_intent.dart';
import 'package:ustaad_ai_app/services/intent_parser_service.dart';

void main() {
  test('intent parses Roman Urdu location and time separately', () {
    final intent = IntentParserService.instance.parseMessage(
      'Mujhy Plumber chahye subha bajy, Ferozpur my',
    );
    expect(intent.service, 'Plumber');
    expect(intent.location?.toLowerCase(), contains('ferozpur'));
    expect(intent.time?.toLowerCase(), isNot(contains('ferozpur')));
    expect(intent.isComplete, true);
  });

}
