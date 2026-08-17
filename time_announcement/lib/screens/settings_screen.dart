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
class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
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

  // A row for a single permission, showing its label, status, and an "Open Settings" button if it's not granted.
  Widget _permissionRow(String label, PermissionStatus? status) {
    final isGranted = status?.isGranted ?? false;
    return ListTile(
      title: Text(label),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget> [
            Text(status == null ? 'Checking...' : _label(status)),
          ]
        )
      )
      actions: <Widget>[
        TextButton(
          child: const Text('Approve'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      trailing: isGranted
          ? null
          : TextButton(
              barrierDismissible: false,
              onPressed: () => _permissionService.openSettings(),
              child: const Text('Open Settings'),
            ),
    );
  }
  
  // The build method constructs the UI for the Settings screen, displaying the permission rows and a placeholder for volume settings.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _permissionRow('Notifications', _notificationStatus),
          _permissionRow('Exact Alarm', _exactAlarmStatus),
          const Divider(),
          const ListTile(title: Text('Volume (TODO)')),
        ],
      ),
    );
  }
}