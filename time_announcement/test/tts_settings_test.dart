import 'package:flutter_test/flutter_test.dart';
import 'package:time_announcement/models/tts_settings.dart';

void main() {
  test('defaults', () {
    const s = TtsSettings();
    expect(s.followSystemVolume, isTrue);
    expect(s.appVolume, 1.0);
    expect(s.speechRate, 0.5);
  });

  test('clamps appVolume and speechRate', () {
    const hi = TtsSettings(appVolume: 2.0, speechRate: 3.0);
    expect(hi.appVolume, 1.0);
    expect(hi.speechRate, 1.0);
    const lo = TtsSettings(appVolume: -1.0, speechRate: -0.5);
    expect(lo.appVolume, 0.0);
    expect(lo.speechRate, 0.0);
    expect(const TtsSettings().copyWith(speechRate: 5).speechRate, 1.0);
  });

  test('effectiveVolume in both modes', () {
    expect(const TtsSettings(appVolume: 0.2).effectiveVolume, 1.0);
    expect(
      const TtsSettings(
        followSystemVolume: false,
        appVolume: 0.2,
      ).effectiveVolume,
      0.2,
    );
  });

  test('copyWith', () {
    const s = TtsSettings();
    final c = s.copyWith(followSystemVolume: false, appVolume: 0.4);
    expect(c.followSystemVolume, isFalse);
    expect(c.appVolume, 0.4);
    expect(c.speechRate, 0.5);
    expect(s.copyWith(), s);
  });

  test('equality and hashCode', () {
    const a = TtsSettings(appVolume: 0.3);
    const b = TtsSettings(appVolume: 0.3);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == a.copyWith(speechRate: 0.9), isFalse);
  });
}
