import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/local_storage_service.dart';
import '../services/permission_service.dart';
import '../services/tts_service.dart';
import '../utils/time_formatter.dart';

// Placeholder Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// re-check status whenever the app resumes, so returning from device Settings updates automatically
class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final _permissionService = PermissionService();
  final _storageService = LocalStorageService();
  final _ttsService = TtsService();
  PermissionStatus? _notificationStatus;
  PermissionStatus? _exactAlarmStatus;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionStatus();
    _ttsService.initialize();
    _loadTtsSettings();
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

  Future<void> _loadTtsSettings() async {
    final speechRate = await _storageService.loadSpeechRate();
    await _ttsService.setSpeechRate(speechRate);
    if (mounted) {
      setState(() {
        _speechRate = speechRate;
      });
    }
  }

  void _onSpeechRateChanged(double value) {
    setState(() => _speechRate = value);
    _ttsService.setSpeechRate(value);
    _storageService.saveSpeechRate(value);
  }

  Future<void> _testVoice() {
    return _ttsService.speak("It's ${TimeFormatter.spoken(TimeOfDay.now())}");
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
          const Divider(),
          ListTile(
            title: const Text('Speech Rate'),
            subtitle: Slider(
              value: _speechRate,
              min: 0.0,
              max: 1.0,
              onChanged: _onSpeechRateChanged,
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: _testVoice,
              child: const Text('Test Voice'),
            ),
          ),
        ],
      ),
    );
  }
}
