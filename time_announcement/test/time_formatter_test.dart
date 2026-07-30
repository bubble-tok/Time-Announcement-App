import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_annoucement/utils/time_formatter.dart';

void main() {
  group('TimeFormatter.format', () {
    test('midnight is 12:00 AM', () {
      expect(
        TimeFormatter.format(const TimeOfDay(hour: 0, minute: 0)),
        '12:00 AM',
      );
    });

    test('noon is 12:00 PM', () {
      expect(
        TimeFormatter.format(const TimeOfDay(hour: 12, minute: 0)),
        '12:00 PM',
      );
    });

    test('1:00 PM formats correctly', () {
      expect(
        TimeFormatter.format(const TimeOfDay(hour: 13, minute: 0)),
        '1:00 PM',
      );
    });

    test('12:23 AM formats correctly (minute is not dropped)', () {
      expect(
        TimeFormatter.format(const TimeOfDay(hour: 0, minute: 23)),
        '12:23 AM',
      );
    });

    test('9:00 AM formats correctly', () {
      expect(
        TimeFormatter.format(const TimeOfDay(hour: 9, minute: 0)),
        '9:00 AM',
      );
    });
  });
}
