import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/tts_settings.dart';
import '../services/storage_service.dart';
import '../services/announcement_controller.dart';
import '../services/permission_service.dart';
import '../services/tts_service.dart';
import '../utils/time_formatter.dart';

/// Settings screen: permissions and speech (volume / rate) settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// re-check status whenever the app resumes, so returning from device Settings updates automatically
class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late final PermissionService _permissionService;
  late final StorageService _storageService;
  late final TtsService _ttsService;
  PermissionStatus? _notificationStatus;
  PermissionStatus? _exactAlarmStatus;
  TtsSettings _settings = const TtsSettings();

  @override
  void initState() {
    super.initState();
    _permissionService = context.read<PermissionService>();
    _storageService = context.read<StorageService>();
    _ttsService = context.read<TtsService>();
    WidgetsBinding.instance.addObserver(this);
    refreshPermissionStatus();
    loadTtsSettings();
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

    if (mounted) {
      setState(() {
        _notificationStatus = notification;
        _exactAlarmStatus = exactAlarm;
      });
    }
  }

  Future<void> loadTtsSettings() async {
    final settings = await _storageService.loadTtsSettings();
    await _ttsService.applySettings(settings);
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  void updateSettings(TtsSettings settings) {
    setState(() => _settings = settings);
    _storageService.saveTtsSettings(settings);
    _ttsService.applySettings(settings);
  }

  String rateLabel(double rate) {
    if (rate < 0.35) return 'Slow';
    if (rate > 0.65) return 'Fast';
    return 'Normal';
  }

  Future<void> testVoice() {
    return _ttsService.speak("It's ${TimeFormatter.spoken(TimeOfDay.now())}");
  }

  String label(PermissionStatus status) {
    if (status.isGranted) return 'Granted';
    if (status.isPermanentlyDenied) return 'Permanently denied';
    if (status.isDenied) return 'Denied';
    return status.toString();
  }

  // single permission row with its label status and open settings button if not granted
  Widget permissionRow(
    String title,
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
          refreshPermissionStatus();
        },
        child: const Text('Approve'),
      );
    }

    return ListTile(
      title: Text(title),
      subtitle: Text(status == null ? 'Checking...' : label(status)),
      trailing: trailing,
    );
  }

  // constructs the UI for the Settings screen, displaying the permission rows and the speech settings.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          permissionRow(
            'Notifications',
            _notificationStatus,
            _permissionService.requestNotification,
          ),
          permissionRow(
            'Exact Alarm',
            _exactAlarmStatus,
            _permissionService.requestExactAlarm,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Follow system volume'),
            value: _settings.followSystemVolume,
            onChanged: (value) =>
                updateSettings(_settings.copyWith(followSystemVolume: value)),
          ),
          if (!_settings.followSystemVolume)
            ListTile(
              title: Text(
                'App volume (${(_settings.appVolume * 100).round()}%)',
              ),
              subtitle: Slider(
                value: _settings.appVolume,
                min: 0.0,
                max: 1.0,
                label: '${(_settings.appVolume * 100).round()}%',
                onChanged: (value) =>
                    updateSettings(_settings.copyWith(appVolume: value)),
              ),
            ),
          const Divider(),
          ListTile(
            title: Text('Speech Rate (${rateLabel(_settings.speechRate)})'),
            subtitle: Slider(
              value: _settings.speechRate.clamp(0.1, 1.0).toDouble(),
              min: 0.1,
              max: 1.0,
              onChanged: (value) =>
                  updateSettings(_settings.copyWith(speechRate: value)),
              // iOS bakes the rate into pre-rendered clips; re-render them
              // once the user lets go of the slider.
              onChangeEnd: (_) {
                if (defaultTargetPlatform == TargetPlatform.iOS) {
                  context.read<AnnouncementController>().reschedule();
                }
              },
            ),
          ),
          if (defaultTargetPlatform == TargetPlatform.iOS)
            const ListTile(
              leading: Icon(Icons.info_outline),
              subtitle: Text(
                'On iPhone, scheduled announcements play at your ringer volume. '
                'These settings apply to Test Voice.',
              ),
            ),
          ListTile(
            title: ElevatedButton(
              onPressed: testVoice,
              child: const Text('Test Voice'),
            ),
          ),
        ],
      ),
    );
  }
}
