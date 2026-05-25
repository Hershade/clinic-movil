import 'package:flutter/material.dart';

class DateFormatUtils {
  static String _two(int n) => n.toString().padLeft(2, '0');

  static String formatDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  static String displayDate(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year}';
  }

  static String formatTime(TimeOfDay time) {
    return '${_two(time.hour)}:${_two(time.minute)}';
  }
}
