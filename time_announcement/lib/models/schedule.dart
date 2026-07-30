import 'package:flutter/material.dart';

// isEnabled is tied to the global ON/OFF toggle (loaded from storage
// elsewhere). announceTimes defaults to the hardcoded beta schedule but is
// still a real constructor parameter -- in beta, only one Schedule is ever
// created and it always uses the default, but this keeps the class reusable
// as-is for a future per-day schedule (Map<Weekday, Schedule>) where each
// day could have its own times list, without needing to restructure this
// class later.
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
