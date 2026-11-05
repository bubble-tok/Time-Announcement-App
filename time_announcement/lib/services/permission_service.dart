import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification and exact-alarm permissions.
///
/// permission_handler only supports Android and iOS (and partially web), so on
/// other platforms (macOS, Windows, Linux, web) everything is reported as
/// granted and requests are no-ops. Exact alarms are Android-only.
class PermissionService {
  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get _usesExactAlarms =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<PermissionStatus> notificationStatus() async {
    if (!_isMobile) return PermissionStatus.granted;
    return Permission.notification.status;
  }

  Future<PermissionStatus> exactAlarmStatus() async {
    if (!_usesExactAlarms) return PermissionStatus.granted;
    return Permission.scheduleExactAlarm.status;
  }

  Future<void> requestAllPermissions() async {
    if (!_isMobile) return;
    final permissions = [
      Permission.notification,
      if (_usesExactAlarms) Permission.scheduleExactAlarm,
    ];
    await permissions.request();
  }

  // Requests notification permission from the user
  Future<PermissionStatus> requestNotification() async {
    if (!_isMobile) return PermissionStatus.granted;
    return Permission.notification.request();
  }

  Future<PermissionStatus> requestExactAlarm() async {
    if (!_usesExactAlarms) return PermissionStatus.granted;
    return Permission.scheduleExactAlarm.request();
  }

  // Opens the device's app settings page, for when a permission is denied
  Future<bool> openSettings() async {
    if (!_isMobile) return false;
    return openAppSettings();
  }
}
