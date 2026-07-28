import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> notificationStatus() =>
      Permission.notification.status;

  Future<PermissionStatus> exactAlarmStatus() async {
    if (kIsWeb) return PermissionStatus.granted;
    return Permission.scheduleExactAlarm.status;
  }

  Future<void> requestAllPermissions() async {
    final permissions = [
      Permission.notification,
      if (!kIsWeb) Permission.scheduleExactAlarm,
    ];
    await permissions.request();
  }

  // Opens the device's app settings page, for when a permission is denied
  Future<bool> openSettings() => openAppSettings();
}
