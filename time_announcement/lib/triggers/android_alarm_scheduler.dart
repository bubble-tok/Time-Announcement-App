import 'dart:ui' show DartPluginRegistrant;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tts_settings.dart';
import '../services/local_storage_service.dart';
import '../services/tts_service.dart';
import '../utils/time_formatter.dart';
import 'schedule_math.dart';
import 'scheduler_service.dart';

/// Android: one exact one-shot alarm per announcement time. Each alarm speaks
/// in a background isolate and then re-arms itself for the next day (exact
/// repeating alarms are not available on modern Android).
class AndroidAlarmScheduler implements SchedulerService {
  static const _scheduledIdsKey = 'scheduledAlarmIds';

  @override
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  @override
  Future<void> scheduleAll(List<TimeOfDay> times, TtsSettings settings) async {
    await cancelAll();
    final now = DateTime.now();
    final ids = <String>[];
    for (final time in times) {
      final id = ScheduleMath.idFor(time);
      await _arm(time, id, now);
      ids.add('$id');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_scheduledIdsKey, ids);
  }

  @override
  Future<void> cancelAll() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_scheduledIdsKey) ?? const [];
    for (final id in ids) {
      await AndroidAlarmManager.cancel(int.parse(id));
    }
    await prefs.remove(_scheduledIdsKey);
  }

  static Future<bool> _arm(TimeOfDay time, int id, DateTime after) {
    return AndroidAlarmManager.oneShotAt(
      ScheduleMath.nextOccurrence(time, after),
      id,
      announceAlarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
  }
}

/// Runs in a background isolate when an announcement alarm fires. Must be a
/// top-level function annotated as an entry point so release builds keep it.
@pragma('vm:entry-point')
Future<void> announceAlarmCallback(int id) async {
  DartPluginRegistrant.ensureInitialized();
  final firedAt = DateTime.now();

  // The background engine is reused across alarms, so drop any cached values
  // to pick up toggle/settings changes made in the UI isolate.
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final storage = LocalStorageService();
  if (!await storage.loadGlobalEnabled()) return;

  final scheduled = ScheduleMath.timeForId(id);
  // Re-arm first so a TTS failure can't break tomorrow's announcement. Look a
  // minute ahead so an early-firing alarm doesn't re-arm for today.
  await AndroidAlarmScheduler._arm(
    scheduled,
    id,
    firedAt.add(const Duration(minutes: 1)),
  );

  final tts = TtsService();
  await tts.initialize();
  await tts.applySettings(await storage.loadTtsSettings());
  final time = ScheduleMath.timeToAnnounce(scheduled, firedAt);
  await tts.speak("It's ${TimeFormatter.spoken(time)}");
}
