import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/tts_settings.dart';
import 'android_alarm_scheduler.dart';
import 'ios_notification_scheduler.dart';

/// Schedules the daily announcements with the operating system so they fire
/// even when the app is backgrounded or killed.
abstract class SchedulerService {
  Future<void> initialize();

  /// Replaces any existing announcements with one per entry in [times],
  /// repeating daily. [settings] is used by platforms that pre-render audio.
  Future<void> scheduleAll(List<TimeOfDay> times, TtsSettings settings);

  Future<void> cancelAll();

  /// Android: exact alarms + background TTS. iOS: notifications with
  /// pre-rendered speech clips. Elsewhere: no-op.
  static SchedulerService forPlatform() {
    if (kIsWeb) return NoopScheduler();
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidAlarmScheduler(),
      TargetPlatform.iOS => IosNotificationScheduler(),
      _ => NoopScheduler(),
    };
  }
}

/// Used on platforms without background scheduling support, and in tests.
class NoopScheduler implements SchedulerService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleAll(List<TimeOfDay> times, TtsSettings settings) async {}

  @override
  Future<void> cancelAll() async {}
}
