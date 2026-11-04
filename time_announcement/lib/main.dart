import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/announcement_controller.dart';
import 'services/local_storage_service.dart';
import 'services/permission_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'triggers/scheduler_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storage = LocalStorageService();
  final permissions = PermissionService();
  final tts = TtsService();
  final scheduler = SchedulerService.forPlatform();

  // Ask for permissions once, on first launch. Afterwards the Home banner and
  // Settings screen let the user fix them.
  if (!await storage.loadHasLaunchedBefore()) {
    await permissions.requestAllPermissions();
    await storage.saveHasLaunchedBefore(true);
  }

  await scheduler.initialize();
  await tts.initialize();
  await tts.applySettings(await storage.loadTtsSettings());

  final controller = AnnouncementController(
    storage: storage,
    scheduler: scheduler,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<PermissionService>.value(value: permissions),
        Provider<TtsService>.value(value: tts),
        ChangeNotifierProvider<AnnouncementController>.value(value: controller),
      ],
      child: const MyApp(),
    ),
  );

  // Not awaited: rendering iOS clips takes a moment and shouldn't delay UI.
  controller.syncOnLaunch();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Announcement',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
