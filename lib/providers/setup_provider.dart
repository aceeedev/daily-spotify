import 'package:flutter/material.dart';

class SetupForm with ChangeNotifier {
  int _step = 0;
  bool _finishedStep = false;

  int _maxNumSelections = 3;

  List<String> _totalGenreList = [];
  List<String> _selectedGenreList = [];

  int get step => _step;
  bool get finishedStep => _finishedStep;
  List<String> get totalGenreList => _totalGenreList;
  List<String> get selectedGenreList => _selectedGenreList;

  void addToStep(int value) {
    _step += value;
    notifyListeners();
  }

  void setFinishedStep(bool value) {
    _finishedStep = value;
    notifyListeners();
  }

  void addAllToTotalGenreList(List<String> listToAdd) {
    _totalGenreList.addAll(listToAdd);
    notifyListeners();
  }

  String? addToSelectedGenreList(String genre) {
    if (_selectedGenreList.length >= _maxNumSelections) {
      return null;
    }

    _selectedGenreList.add(genre);

    return genre;
  }

  void removeFromSelectedGenreList(String genre) {
    _selectedGenreList.remove(genre);
  }
}
