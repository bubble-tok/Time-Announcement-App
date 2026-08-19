import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/local_storage_service.dart';
import '../services/permission_service.dart';
import 'settings_screen.dart';

// Placeholder Home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// WidgetsBindingObserver lets us hook into app lifecycle events. We use it to re-check permission status when the app resumes
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _permissionService = PermissionService();
  final _storageService = LocalStorageService();
  bool _permissionsGranted = true;
  bool _globalEnabled = false;
  bool _userToggled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionStatus();
    _loadGlobalEnabled();
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
    final allGranted = notification.isGranted && exactAlarm.isGranted;

    if (mounted) {
      setState(() => _permissionsGranted = allGranted);
    }
  }


  Future<void> _loadGlobalEnabled() async {
    final enabled = await _storageService.loadGlobalEnabled();

    if (mounted && !_userToggled) {
      setState(() => _globalEnabled = enabled);
    }
  }

  void _onGlobalEnabledChanged(bool value) {
    _userToggled = true;
    setState(() => _globalEnabled = value);
    _storageService.saveGlobalEnabled(value);
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Announcement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: const Text('Fix in Settings'),
                ),
                ElevatedButton(
                  onPressed: _showMyDialog,
                  child: const Text('placeholder'),
                ),
              ],
            ),
          Expanded(
            child: Center(
              child: SwitchListTile(
                title: const Text('Announcements'),
                value: _globalEnabled,
                onChanged: _onGlobalEnabledChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
