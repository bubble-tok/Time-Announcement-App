import 'package:flutter/material.dart';

/// Pure scheduling helpers, kept free of plugins so they are unit-testable.
class ScheduleMath {
  /// Offset so announcement IDs never collide with other alarms/notifications.
  static const idBase = 1000;

  /// Stable ID for a time of day: one per minute of the day.
  static int idFor(TimeOfDay time) => idBase + time.hour * 60 + time.minute;

  static TimeOfDay timeForId(int id) {
    final minuteOfDay = id - idBase;
    if (minuteOfDay < 0 || minuteOfDay >= 24 * 60) {
      throw ArgumentError.value(id, 'id', 'not an announcement id');
    }
    return TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  }

  /// The next local DateTime at [time] strictly after [now].
  static DateTime nextOccurrence(TimeOfDay time, DateTime now) {
    final today = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // Use calendar-day arithmetic (not Duration(days: 1)) so DST shifts
    // don't move the announcement by an hour.
    return today.isAfter(now)
        ? today
        : DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
  }

  /// What to say when an alarm for [scheduled] fires at [firedAt]: the
  /// scheduled time if on time, or the actual time if the OS delivered it
  /// more than [tolerance] late (e.g. deferred by battery optimisation).
  static TimeOfDay timeToAnnounce(
    TimeOfDay scheduled,
    DateTime firedAt, {
    Duration tolerance = const Duration(minutes: 2),
  }) {
    final scheduledAt = DateTime(
      firedAt.year,
      firedAt.month,
      firedAt.day,
      scheduled.hour,
      scheduled.minute,
    );
    final late = firedAt.difference(scheduledAt);
    return late > tolerance ? TimeOfDay.fromDateTime(firedAt) : scheduled;
  }
}
