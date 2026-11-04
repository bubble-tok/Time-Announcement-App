import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification and exact-alarm permissions. Exact alarms are Android-only;
/// elsewhere they are reported as granted.
class PermissionService {
  static bool get _usesExactAlarms =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<PermissionStatus> notificationStatus() =>
      Permission.notification.status;

  Future<PermissionStatus> exactAlarmStatus() async {
    if (!_usesExactAlarms) return PermissionStatus.granted;
    return Permission.scheduleExactAlarm.status;
  }

  Future<void> requestAllPermissions() async {
    final permissions = [
      Permission.notification,
      if (_usesExactAlarms) Permission.scheduleExactAlarm,
    ];
    await permissions.request();
  }

  // Requests notification permission from the user
  Future<PermissionStatus> requestNotification() =>
      Permission.notification.request();

  Future<PermissionStatus> requestExactAlarm() async {
    if (!_usesExactAlarms) return PermissionStatus.granted;
    return Permission.scheduleExactAlarm.request();
  }

  // Opens the device's app settings page, for when a permission is denied
  Future<bool> openSettings() => openAppSettings();
}
