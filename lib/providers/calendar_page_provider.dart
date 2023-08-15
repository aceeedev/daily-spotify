import 'package:flutter/material.dart';

class CalendarPageProvider with ChangeNotifier {
  int _streak = 0;

  int get streak => _streak;

  void setStreak(int value) => _streak = value;

  void addToStreak({int value = 1}) => _streak += value;
}
