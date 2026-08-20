import 'package:flutter/material.dart';

// Formats a TimeOfDay as a 12-hour clock string
class TimeFormatter {
  static String format(TimeOfDay time) {
    final hour12 = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  // Formats a TimeOfDay as a natural spoken phrase for TTS
  static String spoken(TimeOfDay time) {
    final hourWord = numberWords[time.hourOfPeriod];
    final minuteWord = _spokenMinute(time.minute);
    final period = time.period == DayPeriod.am ? 'a.m.' : 'p.m.';
    return minuteWord.isEmpty
        ? '$hourWord $period'
        : '$hourWord $minuteWord $period';
  }

  static String _spokenMinute(int minute) {
    if (minute == 0) return '';
    if (minute < 10) return 'oh ${numberWords[minute]}';
    return _numberToWords(minute);
  }

  static String _numberToWords(int n) {
    if (n < 20) return numberWords[n];
    final tens = tensWords[n ~/ 10];
    final ones = n % 10;
    return ones == 0 ? tens : '$tens-${numberWords[ones]}';
  }

  static const numberWords = [
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen',
  ];
  static const tensWords = ['', '', 'twenty', 'thirty', 'forty', 'fifty'];
}
