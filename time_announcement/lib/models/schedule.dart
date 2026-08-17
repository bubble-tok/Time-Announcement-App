import 'package:flutter/material.dart';

/**
 * Schedule represents the user's schedule. It contains a flag indicating whether announcements are enabled,
 */
class Schedule {
  final bool isEnabled;
  final List<TimeOfDay> announceTimes;

  Schedule({required this.isEnabled, List<TimeOfDay>? announceTimes})
    : announceTimes = announceTimes ?? _defaultAnnounceTimes;

  // Hourly on the hour, 9:00 AM through 10:00 PM.
  static final List<TimeOfDay> _defaultAnnounceTimes = List.generate(
    14,
    (i) => TimeOfDay(hour: 9 + i, minute: 0),
  );
}
