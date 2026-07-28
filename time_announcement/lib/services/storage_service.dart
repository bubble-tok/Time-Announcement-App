// 4 settings, each with its own save/load pair (8 methods total). Storage
// backends like SharedPreferences only expose a single write call and a
// single read call per value -- there's no read+write in one -- so every
// piece of persisted state needs both a save and a load method here.
abstract class StorageServce {
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
}
