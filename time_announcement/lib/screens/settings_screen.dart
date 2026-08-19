import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

// Placeholder Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// re-check status whenever the app resumes, so returning from device Settings updates the rows automatically
class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final _permissionService = PermissionService();
  PermissionStatus? _notificationStatus;
  PermissionStatus? _exactAlarmStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    final notification = await _permissionService.notificationStatus();
    final exactAlarm = await _permissionService.exactAlarmStatus();

    if (mounted) {
      setState(() {
        _notificationStatus = notification;
        _exactAlarmStatus = exactAlarm;
      });
    }
  }

  String _label(PermissionStatus status) {
    if (status.isGranted) return 'Granted';
    if (status.isPermanentlyDenied) return 'Permanently denied';
    if (status.isDenied) return 'Denied';
    return status.toString();
  }

  // single permission row with its label status and open settings button if not granted
  Widget _permissionRow(
    String label,
    PermissionStatus? status,
    Future<PermissionStatus> Function() request,
  ) {
    Widget? trailing;
    if (status != null && status.isPermanentlyDenied) {
      trailing = TextButton(
        onPressed: () => _permissionService.openSettings(),
        child: const Text('Open Settings'),
      );
    } else if (status != null && !status.isGranted) {
      trailing = TextButton(
        onPressed: () async {
          await request();
          _refreshPermissionStatus();
        },
        child: const Text('Approve'),
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: Text(status == null ? 'Checking...' : _label(status)),
      trailing: trailing,
    );
  }

  // constructs the UI for the Settings screen, displaying the permission rows and a placeholder for volume settings.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _permissionRow(
            'Notifications',
            _notificationStatus,
            _permissionService.requestNotification,
          ),
          _permissionRow(
            'Exact Alarm',
            _exactAlarmStatus,
            _permissionService.requestExactAlarm,
          ),
          const Divider(),
          const ListTile(title: Text('Volume (TODO)')),
        ],
      ),
    );
  }
}
