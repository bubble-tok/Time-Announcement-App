import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_announcement/triggers/schedule_math.dart';

void main() {
  group('idFor / timeForId', () {
    for (final t in const [
      TimeOfDay(hour: 0, minute: 0),
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 23, minute: 59),
    ]) {
      test('round-trips ${t.hour}:${t.minute}', () {
        expect(ScheduleMath.timeForId(ScheduleMath.idFor(t)), t);
      });
    }

    test('ids are offset by idBase', () {
      expect(ScheduleMath.idFor(const TimeOfDay(hour: 0, minute: 0)), 1000);
      expect(ScheduleMath.idFor(const TimeOfDay(hour: 9, minute: 0)), 1540);
    });

    test('timeForId throws ArgumentError when out of range', () {
      expect(() => ScheduleMath.timeForId(999), throwsArgumentError);
      expect(() => ScheduleMath.timeForId(0), throwsArgumentError);
      expect(() => ScheduleMath.timeForId(1000 + 1440), throwsArgumentError);
    });
  });

  group('nextOccurrence', () {
    const nine = TimeOfDay(hour: 9, minute: 0);

    test('later today', () {
      expect(
        ScheduleMath.nextOccurrence(nine, DateTime(2025, 3, 10, 8, 30)),
        DateTime(2025, 3, 10, 9, 0),
      );
    });

    test('exactly now goes to tomorrow', () {
      expect(
        ScheduleMath.nextOccurrence(nine, DateTime(2025, 3, 10, 9, 0)),
        DateTime(2025, 3, 11, 9, 0),
      );
    });

    test('earlier today goes to tomorrow', () {
      expect(
        ScheduleMath.nextOccurrence(nine, DateTime(2025, 3, 10, 15, 0)),
        DateTime(2025, 3, 11, 9, 0),
      );
    });

    test('rolls over month and year', () {
      expect(
        ScheduleMath.nextOccurrence(nine, DateTime(2025, 12, 31, 23, 30)),
        DateTime(2026, 1, 1, 9, 0),
      );
    });
  });

  group('timeToAnnounce', () {
    const nine = TimeOfDay(hour: 9, minute: 0);

    test('on time uses scheduled time', () {
      expect(
        ScheduleMath.timeToAnnounce(nine, DateTime(2025, 3, 10, 9, 0)),
        nine,
      );
    });

    test('1 minute late still uses scheduled time', () {
      expect(
        ScheduleMath.timeToAnnounce(nine, DateTime(2025, 3, 10, 9, 1)),
        nine,
      );
    });

    test('5 minutes late uses actual time', () {
      expect(
        ScheduleMath.timeToAnnounce(nine, DateTime(2025, 3, 10, 9, 5)),
        const TimeOfDay(hour: 9, minute: 5),
      );
    });
  });
}
