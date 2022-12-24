import 'package:flutter/material.dart';

class SetupForm with ChangeNotifier {
  int _step = 0;
  bool _finishedStep = false;

  int get step => _step;
  bool get finishedStep => _finishedStep;

  void addToStep(int value) {
    _step += value;
    notifyListeners();
  }

  void setFinishedStep(bool value) {
    _finishedStep = value;
    notifyListeners();
  }
}
