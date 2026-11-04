import 'package:flutter_test/flutter_test.dart';
import 'package:time_announcement/services/tts_service.dart';

void main() {
  group('TtsService.pickLanguage', () {
    test('en-US available -> en-US', () {
      expect(TtsService.pickLanguage('en-US', true), 'en-US');
    });

    test('en-GB available -> en-GB', () {
      expect(TtsService.pickLanguage('en-GB', true), 'en-GB');
    });

    test('en-GB unavailable -> en-US', () {
      expect(TtsService.pickLanguage('en-GB', false), 'en-US');
    });

    test('ko-KR available -> en-US', () {
      expect(TtsService.pickLanguage('ko-KR', true), 'en-US');
    });
  });
}
