import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

class TrackViewProvider with ChangeNotifier {
  bool _emojiReactionClicked = false;
  final List<Track> _excludeTrackList = [];

  bool get emojiReactionClicked => _emojiReactionClicked;
  List<Track> get excludeTrackList => _excludeTrackList;

  void setEmojiReactionClicked(bool value) {
    _emojiReactionClicked = value;
    notifyListeners();
  }

  /// Inverts [emojiReactionClicked]
  void switchEmojiReactionClicked() =>
      setEmojiReactionClicked(!_emojiReactionClicked);

  void addToExcludeTrackList(Track track) => _excludeTrackList.add(track);
}
