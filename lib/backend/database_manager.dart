import 'package:async/async.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

class Auth {
  static final Auth instance = Auth._init();
  static Box? _box;

  Auth._init();

  Future<Box> get box async {
    if (_box != null) return _box!;

    _box = await Hive.openBox('auth');
    return _box!;
  }

  Future<void> saveAuthCode(String code) async =>
      (await box).put('authCode', code);

  Future<String> getAuthCode() async => (await box).get('authCode');

  Future<void> saveAccessToken(AccessToken accessToken) async =>
      (await box).put('accessToken', accessToken);

  Future<AccessToken?> getAccessToken() async => (await box).get('accessToken');
}

class Config {
  static final Config instance = Config._init();
  static Box? _box;

  Config._init();

  Future<Box> get box async {
    if (_box != null) return _box!;

    _box = await Hive.openBox('config');
    return _box!;
  }

  Future<void> saveGenreConfig(List<String> genreList) async =>
      (await box).put('genre', genreList);

  Future<void> saveArtistConfig(List<Artist> artistList) async =>
      (await box).put('artist', artistList);

  Future<void> saveTrackConfig(List<Track> trackList) async =>
      (await box).put('track', trackList);

  Future<List<String>> getGenreConfig() async => (await box).get('genre');

  Future<List<Artist>> getArtistConfig() async => (await box).get('artist');

  Future<List<Track>> getTrackConfig() async => (await box).get('track');
}

class Songs {}
