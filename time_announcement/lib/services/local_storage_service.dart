import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/**
 * LocalStorageService is a concrete implementation of StorageService 
 * that uses SharedPreferences for persistent storage.
 */
class LocalStorageService implements StorageService {
  static const _hasLaunchedBeforeKey = 'hasLaunchedBefore';
  static const _globalEnabledKey = 'globalEnabled';
  static const _appVolumeKey = 'appVolume';
  static const _followSystemVolumeKey = 'followSystemVolume';

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
}
