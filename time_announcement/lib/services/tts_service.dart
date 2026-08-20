import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize() async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale
        .toLanguageTag();
    await _flutterTts.setLanguage(locale);
    // TODO: language/voice picker UI, letting the user override the
    // system-default language and pick a specific voice
  }

  Future<void> setSpeechRate(double rate) => _flutterTts.setSpeechRate(rate);

  Future<void> speak(String text) => _flutterTts.speak(text);
}
