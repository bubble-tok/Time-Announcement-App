import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_tts/flutter_tts.dart';

import '../models/tts_settings.dart';

/// Thin wrapper over flutter_tts used by both the UI and the background
/// announcement isolate.
class TtsService {
  /// Used when the device language is unavailable or not English.
  static const fallbackLanguage = 'en-US';

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // Make speak() complete only after the utterance finishes, so the
    // background isolate is not torn down mid-sentence.
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage(await resolveLanguage());
    _initialized = true;
    // TODO: language/voice picker UI, letting the user override the
    // system-default language and pick a specific voice
  }

  /// The device language when it is an available English variant, otherwise
  /// [fallbackLanguage]. Announcement phrasing is English-only for now, so a
  /// non-English voice would mispronounce it.
  Future<String> resolveLanguage() async {
    final locale = PlatformDispatcher.instance.locale.toLanguageTag();
    return pickLanguage(locale, await _isAvailable(locale));
  }

  static String pickLanguage(String deviceLocale, bool available) =>
      deviceLocale.toLowerCase().startsWith('en') && available
      ? deviceLocale
      : fallbackLanguage;

  Future<bool> _isAvailable(String language) async {
    try {
      final result = await _tts.isLanguageAvailable(language);
      return result == true || result == 1;
    } catch (_) {
      return false;
    }
  }

  Future<void> applySettings(TtsSettings settings) async {
    await _tts.setVolume(settings.effectiveVolume);
    await _tts.setSpeechRate(settings.speechRate);
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();
}
