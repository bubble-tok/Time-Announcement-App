import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/tts_settings.dart';
import '../services/tts_service.dart';
import '../utils/time_formatter.dart';
import 'schedule_math.dart';
import 'scheduler_service.dart';

/// iOS: apps can't run TTS from a scheduled notification, so each time is
/// pre-rendered to an audio clip on device (AVSpeechSynthesizer, see
/// AppDelegate.swift) and used as a daily repeating notification's sound.
/// Notification sounds play at ringer volume; TtsSettings volume is ignored.
class IosNotificationScheduler implements SchedulerService {
  static const _clipChannel = MethodChannel('time_announcement/speech_clips');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final TtsService _tts;

  IosNotificationScheduler({TtsService? tts}) : _tts = tts ?? TtsService();

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    final local = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(local.identifier));

    // Permissions are requested by PermissionService, not here.
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(iOS: darwin),
    );
  }

  @override
  Future<void> scheduleAll(List<TimeOfDay> times, TtsSettings settings) async {
    await cancelAll();
    final language = await _tts.resolveLanguage();
    final now = tz.TZDateTime.now(tz.local);

    for (final time in times) {
      final id = ScheduleMath.idFor(time);
      final fileName = 'announce_$id.caf';
      final wrote = await _writeClip(
        text: "It's ${TimeFormatter.spoken(time)}",
        fileName: fileName,
        language: language,
        rate: settings.speechRate,
      );

      await _plugin.zonedSchedule(
        id: id,
        title: TimeFormatter.format(time),
        body: 'Time announcement',
        scheduledDate: _nextInstance(time, now),
        notificationDetails: NotificationDetails(
          iOS: DarwinNotificationDetails(
            // Fall back to the default sound if the clip couldn't be made.
            sound: wrote ? fileName : null,
            presentSound: true,
            presentAlert: true,
            presentBanner: true,
            presentList: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  tz.TZDateTime _nextInstance(TimeOfDay time, tz.TZDateTime now) {
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!at.isAfter(now)) {
      at = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        time.hour,
        time.minute,
      );
    }
    return at;
  }

  /// Renders [text] to Library/Sounds/[fileName]. Returns false on failure.
  Future<bool> _writeClip({
    required String text,
    required String fileName,
    required String language,
    required double rate,
  }) async {
    try {
      await _clipChannel.invokeMethod<void>('writeClip', {
        'text': text,
        'fileName': fileName,
        'language': language,
        'rate': rate,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint('Speech clip failed for $fileName: ${e.message}');
      return false;
    }
  }
}
