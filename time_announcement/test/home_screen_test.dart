import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_announcement/screens/home_screen.dart';
import 'package:time_announcement/services/announcement_controller.dart';
import 'package:time_announcement/services/local_storage_service.dart';
import 'package:time_announcement/services/permission_service.dart';

import 'fakes.dart';

void main() {
  late FakeScheduler scheduler;
  late AnnouncementController controller;

  Future<void> pump(
    WidgetTester tester, {
    FakePermissionService? permissions,
  }) async {
    SharedPreferences.setMockInitialValues({});
    scheduler = FakeScheduler();
    controller = AnnouncementController(
      storage: LocalStorageService(),
      scheduler: scheduler,
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PermissionService>.value(
            value: permissions ?? FakePermissionService(),
          ),
          ChangeNotifierProvider<AnnouncementController>.value(
            value: controller,
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
  }

  Switch theSwitch(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch));

  testWidgets('switch is disabled until syncOnLaunch, then enabled', (
    tester,
  ) async {
    await pump(tester);
    expect(theSwitch(tester).onChanged, isNull);

    await tester.runAsync(controller.syncOnLaunch);
    await tester.pump();

    expect(theSwitch(tester).onChanged, isNotNull);
  });

  testWidgets('tapping the switch turns announcements on and schedules', (
    tester,
  ) async {
    await pump(tester);
    await tester.runAsync(controller.syncOnLaunch);
    await tester.pump();
    expect(theSwitch(tester).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(theSwitch(tester).value, isTrue);
    expect(controller.enabled, isTrue);
    expect(scheduler.scheduleAllCount, 1);
  });

  testWidgets('no banner when permissions are granted', (tester) async {
    await pump(tester);
    expect(find.text('Fix in Settings'), findsNothing);
  });

  testWidgets('banner when notification permission is denied', (tester) async {
    await pump(
      tester,
      permissions: FakePermissionService(notification: PermissionStatus.denied),
    );
    expect(find.text('Fix in Settings'), findsOneWidget);
  });

  testWidgets('banner when exact alarm permission is denied', (tester) async {
    await pump(
      tester,
      permissions: FakePermissionService(exactAlarm: PermissionStatus.denied),
    );
    expect(find.text('Fix in Settings'), findsOneWidget);
  });

  testWidgets('no placeholder text', (tester) async {
    await pump(tester);
    expect(
      find.textContaining('placeholder', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('Placeholder', findRichText: true),
      findsNothing,
    );
  });
}
