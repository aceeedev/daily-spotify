import 'package:flutter/material.dart';

class SetupForm with ChangeNotifier {
  int _step = 0;

  int get step => _step;

  void addToStep(int value) {
    _step += value;
    notifyListeners();
  }
}
