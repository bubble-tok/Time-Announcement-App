import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_announcement/models/tts_settings.dart';
import 'package:time_announcement/services/local_storage_service.dart';

void main() {
  test('LocalStorageService round-trips the global enabled flag', () async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalStorageService();

    expect(await service.loadGlobalEnabled(), isFalse);

    await service.saveGlobalEnabled(true);
    expect(await service.loadGlobalEnabled(), isTrue);
  });
  test('LocalStorageService round-trips TtsSettings', () async {
    SharedPreferences.setMockInitialValues({});
    final service = LocalStorageService();

    expect(await service.loadTtsSettings(), const TtsSettings());

    const settings = TtsSettings(
      followSystemVolume: false,
      appVolume: 0.3,
      speechRate: 0.8,
    );
    await service.saveTtsSettings(settings);
    expect(await service.loadTtsSettings(), settings);
  });

  test('loadSpeechRate clamps legacy values above 1.0', () async {
    SharedPreferences.setMockInitialValues({'speechRate': 3.0});
    final service = LocalStorageService();

    expect(await service.loadSpeechRate(), 1.0);
  });
}
