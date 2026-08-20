/** Abstract
 */
abstract class StorageService {
  // Whether the app has been launched before (first-run vs. relaunch).
  Future<void> saveHasLaunchedBefore(bool value);
  Future<bool> loadHasLaunchedBefore();

  // The global announcements ON/OFF toggle.
  Future<void> saveGlobalEnabled(bool value);
  Future<bool> loadGlobalEnabled();

  // The app's own volume level (used when not following system volume).
  Future<void> saveAppVolume(double value);
  Future<double> loadAppVolume();

  // Whether TTS volume should follow the device's system volume instead.
  Future<void> saveFollowSystemVolume(bool value);
  Future<bool> loadFollowSystemVolume();

  // TTS speech rate.
  Future<void> saveSpeechRate(double value);
  Future<double> loadSpeechRate();
}
