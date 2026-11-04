import 'package:shared_preferences/shared_preferences.dart';
import '../models/tts_settings.dart';
import 'storage_service.dart';

/// [StorageService] implementation backed by shared_preferences.
class LocalStorageService implements StorageService {
  static const _hasLaunchedBeforeKey = 'hasLaunchedBefore';
  static const _globalEnabledKey = 'globalEnabled';
  static const _appVolumeKey = 'appVolume';
  static const _followSystemVolumeKey = 'followSystemVolume';
  static const _speechRateKey = 'speechRate';

  @override
  Future<void> saveHasLaunchedBefore(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasLaunchedBeforeKey, value);
  }

  @override
  Future<bool> loadHasLaunchedBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLaunchedBeforeKey) ?? false;
  }

  @override
  Future<void> saveGlobalEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_globalEnabledKey, value);
  }

  @override
  Future<bool> loadGlobalEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_globalEnabledKey) ?? false;
  }

  @override
  Future<void> saveAppVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_appVolumeKey, value);
  }

  @override
  Future<double> loadAppVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_appVolumeKey) ?? 1.0;
  }

  @override
  Future<void> saveFollowSystemVolume(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemVolumeKey, value);
  }

  @override
  Future<bool> loadFollowSystemVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followSystemVolumeKey) ?? true;
  }

  @override
  Future<void> saveSpeechRate(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speechRateKey, value);
  }

  @override
  Future<double> loadSpeechRate() async {
    final prefs = await SharedPreferences.getInstance();
    // Older builds allowed rates up to 3.0; clamp to the valid range.
    return (prefs.getDouble(_speechRateKey) ?? 0.5).clamp(0.0, 1.0).toDouble();
  }

  @override
  Future<TtsSettings> loadTtsSettings() async {
    return TtsSettings(
      followSystemVolume: await loadFollowSystemVolume(),
      appVolume: await loadAppVolume(),
      speechRate: await loadSpeechRate(),
    );
  }

  @override
  Future<void> saveTtsSettings(TtsSettings settings) async {
    await saveFollowSystemVolume(settings.followSystemVolume);
    await saveAppVolume(settings.appVolume);
    await saveSpeechRate(settings.speechRate);
  }
}
