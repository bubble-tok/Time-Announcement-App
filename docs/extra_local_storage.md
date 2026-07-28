# LocalStorageService + Home Screen ON/OFF Toggle — Design

## Context

`StorageService` is an abstract interface
already defined in `lib/services/storage_service.dart` with 8 methods covering
`hasLaunchedBefore`, `globalEnabled`, `appVolume`, and `followSystemVolume`
(save/load pairs for each). `lib/services/local_storage_service.dart`, the
`SharedPreferences`-backed implementation, is currently an empty file.

`HomeScreen` currently shows a placeholder `Text('Home screen (ON/OFF toggle:
TODO)')` instead of a real toggle. This is the next piece of beta scope work,
following the permissions work (TA-8) completed previously.

## Goals

- Implement `LocalStorageService` as a concrete, `SharedPreferences`-backed
  implementation of the full `StorageService` interface.
- Wire `HomeScreen`'s ON/OFF toggle to persist via `saveGlobalEnabled` /
  `loadGlobalEnabled`.
- Fix the `StorageServce` → `StorageService` typo while touching this file.

## Non-goals

- Wiring the toggle to `SchedulerService` (scheduling/canceling announcements)
  — `SchedulerService` doesn't exist yet; that's future work.
- Wiring the toggle to re-request permissions.
- Building the volume slider UI in `SettingsScreen` (still a `TODO` placeholder)
  — `saveAppVolume`/`loadAppVolume`/`saveFollowSystemVolume`/
  `loadFollowSystemVolume` will be implemented (required, since
  `LocalStorageService` must implement the full interface to be a valid
  concrete class) but have no caller yet.
- Wiring `hasLaunchedBefore` into `main.dart`'s launch flow — implemented but
  uncalled, same reasoning as above. That's a separate future ticket
  (main.dart first-launch vs. relaunch flow).
- Unit tests for `LocalStorageService` — it's a thin wrapper around
  `SharedPreferences` with no logic of its own to verify beyond round-tripping,
  covered by `flutter analyze` plus manual toggle-and-restart verification.

## Design

### `StorageService` (renamed from `StorageServce`)

Typo fix only, no signature changes:

```dart
abstract class StorageService {
  Future<void> saveHasLaunchedBefore(bool value);
  Future<bool> loadHasLaunchedBefore();

  Future<void> saveGlobalEnabled(bool value);
  Future<bool> loadGlobalEnabled();

  Future<void> saveAppVolume(double value);
  Future<double> loadAppVolume();

  Future<void> saveFollowSystemVolume(bool value);
  Future<bool> loadFollowSystemVolume();
}
```

### `LocalStorageService`

Implements all 8 methods using `SharedPreferences.getInstance()` per call (no
manual caching needed — the plugin already caches internally). Each save/load
pair uses its own private `static const` string key to avoid retyping literal
strings. Defaults returned when a key has never been saved:

| Method | Key | Default |
|---|---|---|
| `loadHasLaunchedBefore` | `hasLaunchedBefore` | `false` |
| `loadGlobalEnabled` | `globalEnabled` | `false` |
| `loadAppVolume` | `appVolume` | `1.0` |
| `loadFollowSystemVolume` | `followSystemVolume` | `true` |

### `HomeScreen` ON/OFF toggle

Replaces the placeholder `Text` with a `Switch` + label. Same `StatefulWidget`
shape as the existing permission-status code already in this file:

- `LocalStorageService` instantiated directly in the `State` class (matching
  the existing `PermissionService` pattern — no `provider`/`ChangeNotifier`
  introduced for this).
- A `bool _globalEnabled = false` field, defaulting to `false` until the
  stored value loads in `initState` (loading is near-instant with
  `SharedPreferences`, so no loading spinner/disabled state is needed).
- On toggle: update `_globalEnabled` via `setState` immediately, and call
  `saveGlobalEnabled(value)` — no other side effects.

### Error handling

`SharedPreferences` calls do not realistically fail on supported platforms
(no network, no user-facing permission gate) — no special try/catch is added
beyond what the plugin itself provides.

## Testing / verification

- `flutter analyze` must pass clean.
- Manual check: toggle on, hot-restart (or fully stop/relaunch) the app,
  confirm the switch remembers its state.
