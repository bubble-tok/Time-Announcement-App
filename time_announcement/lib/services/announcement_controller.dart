import 'package:flutter/material.dart';

import '../models/schedule.dart';
import '../triggers/scheduler_service.dart';
import 'storage_service.dart';

/// Owns the global ON/OFF state and keeps the OS schedule in sync with it.
class AnnouncementController extends ChangeNotifier {
  final StorageService _storage;
  final SchedulerService _scheduler;
  final List<TimeOfDay> _times;

  bool _enabled = false;
  bool _loaded = false;

  AnnouncementController({
    required this._storage,
    required this._scheduler,
    List<TimeOfDay>? times,
  }) : _times = times ?? Schedule.defaultAnnounceTimes;

  bool get enabled => _enabled;
  bool get loaded => _loaded;

  /// Loads the saved toggle and re-applies it to the OS schedule. Called on
  /// every launch so announcements survive reinstalls, OS clears and setting
  /// changes (iOS clips are re-rendered with the current speech settings).
  Future<void> syncOnLaunch() async {
    _enabled = await _storage.loadGlobalEnabled();
    _loaded = true;
    notifyListeners();
    await _apply();
  }

  Future<void> setEnabled(bool value) async {
    if (value == _enabled && _loaded) return;
    _enabled = value;
    _loaded = true;
    notifyListeners();
    await _storage.saveGlobalEnabled(value);
    await _apply();
  }

  /// Re-schedules if enabled, e.g. after speech settings change.
  Future<void> reschedule() async {
    if (_enabled) await _apply();
  }

  Future<void> _apply() async {
    try {
      if (_enabled) {
        await _scheduler.scheduleAll(_times, await _storage.loadTtsSettings());
      } else {
        await _scheduler.cancelAll();
      }
    } catch (e, st) {
      debugPrint('Failed to sync announcement schedule: $e\n$st');
    }
  }
}
