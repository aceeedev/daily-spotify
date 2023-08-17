import 'package:flutter/material.dart';

class CalendarPageProvider with ChangeNotifier {
  int _streak = 0;
  bool _streaksReady = false;

  int get streak => _streak;
  bool get streaksReady => _streaksReady;

  void setStreak(int value) => _streak = value;

  void addToStreak({int value = 1}) => _streak += value;

  void setStreaksReady(bool value) => _streaksReady = value;
}
