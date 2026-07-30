import 'package:flutter/material.dart';

// Formats a TimeOfDay as a 12-hour clock string, e.g. "9:00 AM", "1:00 PM".
class TimeFormatter {
  static String format(TimeOfDay time) {
    final hour12 = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }
}
