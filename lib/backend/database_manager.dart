import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/models/daily_track.dart';

class Auth {
  static final Auth instance = Auth._init();
  static Box? _box;

  Auth._init();

  Future<Box> get box async {
    if (_box != null) return _box!;

    // encrypted box
    const secureStorage = FlutterSecureStorage();

    // if key not exists return null
    final encryptionKeyString = await secureStorage.read(key: 'key');
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'key',
        value: base64UrlEncode(key),
      );
    }

    final key = await secureStorage.read(key: 'key');
    final encryptionKeyUint8List = base64Url.decode(key!);

    _box = await Hive.openBox('auth',
        encryptionCipher: HiveAesCipher(encryptionKeyUint8List));

    return _box!;
  }

  Future<void> saveAuthCode(String code) async =>
      (await box).put('authCode', code);

  Future<String> getAuthCode() async => (await box).get('authCode');

  Future<void> saveAccessToken(AccessToken accessToken) async =>
      (await box).put('accessToken', accessToken);

  Future<AccessToken?> getAccessToken() async => (await box).get('accessToken');

  Future<void> saveCodeVerifier(String codeVerifier) async =>
      (await box).put('codeVerifier', codeVerifier);

  Future<String> getCodeVerifier() async => (await box).get('codeVerifier');
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

  Future<List<String>> getGenreConfig() async {
    List<String>? genreList = (await box).get('genre');

    return genreList ?? [];
  }

  Future<List<Artist>> getArtistConfig() async {
    List<Artist>? artistList =
        ((await box).get('artist') as List<dynamic>?)?.cast<Artist>();

    return artistList ?? [];
  }

  Future<List<Track>> getTrackConfig() async {
    List<Track>? trackList =
        ((await box).get('track') as List<dynamic>?)?.cast<Track>();

    return trackList ?? [];
  }
}

class Tracks {
  static final Tracks instance = Tracks._init();
  static Box? _box;

  Tracks._init();

  Future<Box> get box async {
    if (_box != null) return _box!;

    _box = await Hive.openBox('tracks');
    return _box!;
  }

  Future<void> saveDailyTrack(DailyTrack dailyTrack) async =>
      (await box).put(DateFormat.yMd().format(dailyTrack.date), dailyTrack);

  Future<DailyTrack?> getDailyTrack(DateTime date) async =>
      (await box).get(DateFormat.yMd().format(date));

  Future<List<DailyTrack>> getAllDailyTracks() async {
    List<DailyTrack> allDailyTracks =
        (await box).values.cast<DailyTrack>().toList();

    allDailyTracks.sort((a, b) => a.date.compareTo(b.date));

    return allDailyTracks;
  }
}
