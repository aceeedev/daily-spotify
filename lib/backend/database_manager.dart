import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_spotify/backend/spotify_api/models/access_token.dart';

class Auth {
  static final Auth instance = Auth._init();
  static Box? _box;

  Auth._init();

  Future<Box> get box async {
    if (_box != null) return _box!;

    _box = await Hive.openBox('auth');
    return _box!;
  }

  Future<void> saveAuthCode(String code) async {
    (await box).put('authCode', code);
  }

  Future<String> getAuthCode() async => (await box).get('authCode');

  Future<void> saveAccessToken(AccessToken accessToken) async {
    (await box).put('accessToken', accessToken);
  }

  Future<AccessToken?> getAccessToken() async => (await box).get('accessToken');
}

class Songs {}
