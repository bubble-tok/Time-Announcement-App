import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../services/announcement_controller.dart';
import '../services/permission_service.dart';
import 'settings_screen.dart';

/// Home screen: the global announcements toggle and a warning banner when
/// required permissions are missing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// WidgetsBindingObserver lets us re-check permission status when the app
// resumes (e.g. returning from the device Settings app).
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final PermissionService _permissionService;
  bool _permissionsGranted = true;

  @override
  void initState() {
    super.initState();
    _permissionService = context.read<PermissionService>();
    WidgetsBinding.instance.addObserver(this);
    refreshPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPermissionStatus();
    }
  }

  Future<void> refreshPermissionStatus() async {
    final notification = await _permissionService.notificationStatus();
    final exactAlarm = await _permissionService.exactAlarmStatus();
    final allGranted = notification.isGranted && exactAlarm.isGranted;

    if (mounted) {
      setState(() => _permissionsGranted = allGranted);
    }
  }

  void openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnnouncementController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Announcement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_permissionsGranted)
            MaterialBanner(
              content: const Text(
                'Warning: Some permissions are off, so announcements may not work.',
              ),
              actions: [
                TextButton(
                  onPressed: openSettings,
                  child: const Text('Fix in Settings'),
                ),
              ],
            ),
          Expanded(
            child: Center(
              child: SwitchListTile(
                title: const Text('Announcements'),
                subtitle: const Text('Every hour, 9 AM to 10 PM'),
                value: controller.enabled,
                onChanged: controller.loaded ? controller.setEnabled : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
