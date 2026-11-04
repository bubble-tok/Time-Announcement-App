import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_announcement/models/schedule.dart';
import 'package:time_announcement/models/tts_settings.dart';
import 'package:time_announcement/services/announcement_controller.dart';
import 'package:time_announcement/services/local_storage_service.dart';

import 'fakes.dart';

void main() {
  late FakeScheduler scheduler;
  late LocalStorageService storage;
  late AnnouncementController controller;

  void setUpWith(Map<String, Object> prefs) {
    SharedPreferences.setMockInitialValues(prefs);
    scheduler = FakeScheduler();
    storage = LocalStorageService();
    controller = AnnouncementController(storage: storage, scheduler: scheduler);
  }

  group('syncOnLaunch', () {
    test('disabled: cancels all and marks loaded', () async {
      setUpWith({'globalEnabled': false});
      await controller.syncOnLaunch();

      expect(controller.enabled, isFalse);
      expect(controller.loaded, isTrue);
      expect(scheduler.cancelAllCount, 1);
      expect(scheduler.scheduleAllCount, 0);
    });

    test('enabled: schedules default times with saved settings', () async {
      setUpWith({
        'globalEnabled': true,
        'followSystemVolume': false,
        'appVolume': 0.3,
        'speechRate': 0.7,
      });
      await controller.syncOnLaunch();

      expect(controller.enabled, isTrue);
      expect(controller.loaded, isTrue);
      expect(scheduler.cancelAllCount, 0);
      expect(scheduler.scheduleAllCount, 1);
      final times = scheduler.scheduledTimes.single;
      expect(times, Schedule.defaultAnnounceTimes);
      expect(times, hasLength(14));
      expect(times.first.hour, 9);
      expect(times.last.hour, 22);
      expect(
        scheduler.scheduledSettings.single,
        const TtsSettings(
          followSystemVolume: false,
          appVolume: 0.3,
          speechRate: 0.7,
        ),
      );
    });
  });

  group('setEnabled', () {
    test('true persists, schedules and notifies', () async {
      setUpWith({});
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.setEnabled(true);

      expect(controller.enabled, isTrue);
      expect(await storage.loadGlobalEnabled(), isTrue);
      expect(scheduler.scheduleAllCount, 1);
      expect(notified, greaterThan(0));
    });

    test('false persists, cancels and notifies', () async {
      setUpWith({'globalEnabled': true});
      await controller.syncOnLaunch();
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.setEnabled(false);

      expect(controller.enabled, isFalse);
      expect(await storage.loadGlobalEnabled(), isFalse);
      expect(scheduler.cancelAllCount, 1);
      expect(notified, greaterThan(0));
    });
  });

  group('reschedule', () {
    test('does nothing while disabled', () async {
      setUpWith({});
      await controller.syncOnLaunch();
      final cancels = scheduler.cancelAllCount;

      await controller.reschedule();

      expect(scheduler.scheduleAllCount, 0);
      expect(scheduler.cancelAllCount, cancels);
    });

    test('schedules when enabled', () async {
      setUpWith({'globalEnabled': true});
      await controller.syncOnLaunch();
      expect(scheduler.scheduleAllCount, 1);

      await controller.reschedule();

      expect(scheduler.scheduleAllCount, 2);
    });
  });

  test('a throwing scheduler does not make setEnabled throw', () async {
    setUpWith({});
    scheduler.error = Exception('boom');

    await controller.setEnabled(true);

    expect(controller.enabled, isTrue);
    expect(await storage.loadGlobalEnabled(), isTrue);
    expect(scheduler.scheduleAllCount, 1);
  });
}
