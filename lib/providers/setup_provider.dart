import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

class SetupForm with ChangeNotifier {
  int _step = 0;
  bool _finishedStep = false;

  static const int _maxNumSelections = 3;

  final List<String> _totalGenreList = [];
  final List<String> _selectedGenreList = [];
  final List<Artist> _totalArtistList = [];
  final List<Artist> _selectedArtistList = [];
  final List<Track> _totalTrackList = [];
  final List<Track> _selectedTrackList = [];

  int get step => _step;
  bool get finishedStep => _finishedStep;
  List<String> get totalGenreList => _totalGenreList;
  List<String> get selectedGenreList => _selectedGenreList;
  List<Artist> get totalArtistList => _totalArtistList;
  List<Artist> get selectedArtistList => _selectedArtistList;
  List<Track> get totalTrackList => _totalTrackList;
  List<Track> get selectedTrackList => _selectedTrackList;

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

  void addAllToTotalArtistList(List<Artist> listToAdd) {
    _totalArtistList.addAll(listToAdd);
  }

  Artist? addToSelectedArtistList(Artist artist) {
    if (_selectedArtistList.length >= _maxNumSelections) {
      return null;
    }

    _selectedArtistList.add(artist);

    return artist;
  }

  void removeFromSelectedArtistList(Artist artist) {
    _selectedArtistList.removeWhere(((element) => element.id == artist.id));
  }

  void addAllToTotalTrackList(List<Track> listToAdd) {
    _totalTrackList.addAll(listToAdd);
  }

  Track? addToSelectedTrackList(Track track) {
    if (_selectedTrackList.length >= _maxNumSelections) {
      return null;
    }

    _selectedTrackList.add(track);

    return track;
  }

  void removeFromSelectedTrackList(Track track) {
    _selectedTrackList.removeWhere((element) => element.id == track.id);
  }
}
