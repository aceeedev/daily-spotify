import 'package:flutter/material.dart';

class TrackViewProvider with ChangeNotifier {
  bool _emojiReactionClicked = false;

  bool get emojiReactionClicked => _emojiReactionClicked;

  void setEmojiReactionClicked(bool value) {
    _emojiReactionClicked = value;
    notifyListeners();
  }

  /// Inverts [emojiReactionClicked]
  void switchEmojiReactionClicked() {
    setEmojiReactionClicked(!_emojiReactionClicked);
  }
}
