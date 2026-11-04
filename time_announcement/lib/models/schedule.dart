import 'package:flutter/material.dart';

/// The user's announcement schedule: whether announcements are enabled and the
/// times of day at which they are spoken.
class Schedule {
  final bool isEnabled;
  final List<TimeOfDay> announceTimes;

  Schedule({required this.isEnabled, List<TimeOfDay>? announceTimes})
    : announceTimes = announceTimes ?? defaultAnnounceTimes;

  /// Hourly on the hour, 9:00 AM through 10:00 PM.
  static final List<TimeOfDay> defaultAnnounceTimes = List.unmodifiable(
    List.generate(14, (i) => TimeOfDay(hour: 9 + i, minute: 0)),
  );
}
