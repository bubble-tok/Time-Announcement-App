import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_announcement/models/tts_settings.dart';
import 'package:time_announcement/services/permission_service.dart';
import 'package:time_announcement/triggers/scheduler_service.dart';

/// Records calls instead of touching the OS.
class FakeScheduler implements SchedulerService {
  final List<List<TimeOfDay>> scheduledTimes = [];
  final List<TtsSettings> scheduledSettings = [];
  int cancelAllCount = 0;
  int initializeCount = 0;

  /// When set, scheduleAll and cancelAll throw this.
  Object? error;

  int get scheduleAllCount => scheduledTimes.length;

  @override
  Future<void> initialize() async => initializeCount++;

  @override
  Future<void> scheduleAll(List<TimeOfDay> times, TtsSettings settings) async {
    scheduledTimes.add(List.of(times));
    scheduledSettings.add(settings);
    if (error != null) throw error!;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    if (error != null) throw error!;
  }
}

class FakePermissionService implements PermissionService {
  PermissionStatus notification;
  PermissionStatus exactAlarm;

  FakePermissionService({
    this.notification = PermissionStatus.granted,
    this.exactAlarm = PermissionStatus.granted,
  });

  @override
  Future<PermissionStatus> notificationStatus() async => notification;

  @override
  Future<PermissionStatus> exactAlarmStatus() async => exactAlarm;

  @override
  Future<void> requestAllPermissions() async {}

  @override
  Future<PermissionStatus> requestNotification() async => notification;

  @override
  Future<PermissionStatus> requestExactAlarm() async => exactAlarm;

  @override
  Future<bool> openSettings() async => true;
}
