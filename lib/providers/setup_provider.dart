import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

class SetupForm with ChangeNotifier {
  int _step = 0;
  bool _finishedStep = false;
  int _lastFinishedStep = -1;

  static const int _maxNumSelections = 3;

  bool _segmentedButtonValue = true;

  final List<String> _totalGenreList = [];
  final List<String> _selectedGenreList = [];
  List<String> _searchedGenreList = [];
  final List<Artist> _totalArtistList = [];
  final List<Artist> _selectedArtistList = [];
  List<Artist> _searchedArtistList = [];
  final List<Track> _totalTrackList = [];
  final List<Track> _selectedTrackList = [];
  List<Track> _searchedTrackList = [];

  int get step => _step;
  bool get finishedStep => _finishedStep;
  int get lastFinishedStep => _lastFinishedStep;
  bool get segmentedButtonValue => _segmentedButtonValue;
  List<String> get totalGenreList => _totalGenreList;
  List<String> get selectedGenreList => _selectedGenreList;
  List<String> get searchedGenreList => _searchedGenreList;
  List<Artist> get totalArtistList => _totalArtistList;
  List<Artist> get selectedArtistList => _selectedArtistList;
  List<Artist> get searchedArtistList => _searchedArtistList;
  List<Track> get totalTrackList => _totalTrackList;
  List<Track> get selectedTrackList => _selectedTrackList;
  List<Track> get searchedTrackList => _searchedTrackList;

  void addToStep(int value) {
    _step += value;

    notifyListeners();
  }

  void setFinishedStep(bool value, {bool notify = true}) {
    _finishedStep = value;

    if (notify) {
      notifyListeners();
    }
  }

  void setLastFinishedStep(int value) {
    _lastFinishedStep = value;

    notifyListeners();
  }

  void toggleSegmentedButtonValue() {
    _segmentedButtonValue = !_segmentedButtonValue;

    notifyListeners();
  }

  void resetSegmentedButtonValue() {
    _segmentedButtonValue = true;

    notifyListeners();
  }

  void addAllToTotalGenreList(List<String> listToAdd) {
    _totalGenreList.addAll(listToAdd);
  }

  String? addToSelectedGenreList(String genre) {
    if (_selectedGenreList.length >= _maxNumSelections ||
        _selectedGenreList.contains(genre)) {
      return null;
    }

    _selectedGenreList.add(genre);

    notifyListeners();
    return genre;
  }

  void removeFromSelectedGenreList(String genre) {
    _selectedGenreList.remove(genre);

    notifyListeners();
  }

  void setSearchedGenreList(List<String> listToSet) {
    _searchedGenreList = listToSet;

    notifyListeners();
  }

  void addAllToTotalArtistList(List<Artist> listToAdd) {
    _totalArtistList.addAll(listToAdd);
  }

  Artist? addToSelectedArtistList(Artist artist) {
    if (_selectedArtistList.length >= _maxNumSelections ||
        _selectedArtistList.contains(artist)) {
      return null;
    }

    _selectedArtistList.add(artist);

    notifyListeners();
    return artist;
  }

  void removeFromSelectedArtistList(Artist artist) {
    _selectedArtistList.removeWhere(((element) => element.id == artist.id));

    notifyListeners();
  }

  void setSearchedArtistList(List<Artist> listToSet) {
    _searchedArtistList = listToSet;

    notifyListeners();
  }

  void addAllToTotalTrackList(List<Track> listToAdd) {
    _totalTrackList.addAll(listToAdd);
  }

  Track? addToSelectedTrackList(Track track) {
    if (_selectedTrackList.length >= _maxNumSelections ||
        _selectedTrackList.contains(track)) {
      return null;
    }

    _selectedTrackList.add(track);

    notifyListeners();
    return track;
  }

  void removeFromSelectedTrackList(Track track) {
    _selectedTrackList.removeWhere((element) => element.id == track.id);

    notifyListeners();
  }

  void setSearchedTrackList(List<Track> listToSet) {
    _searchedTrackList = listToSet;

    notifyListeners();
  }
}
