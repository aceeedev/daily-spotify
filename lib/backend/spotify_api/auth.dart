import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:daily_spotify/secrets.dart' as secrets;
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

const _redirectUriScheme = 'com.example.daily-spotify';

String _getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random.secure();

  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

String _getAuthUrl(String redirectUri, String state) {
  const scope = 'user-top-read';
  redirectUri += '://callback';
  final codeVerifier = _getRandomString(100);
  final hash = sha256.convert(ascii.encode(codeVerifier));
  final codeChallenge = base64Url
      .encode(hash.bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");

  final queryParameters = {
    'response_type': 'code',
    'client_id': secrets.spotifyClientId,
    'scope': scope,
    'redirect_uri': redirectUri,
    'state': state,
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
  };

  final url = Uri.https('accounts.spotify.com', '/authorize', queryParameters)
      .toString();

  // save codeVerifier for later verification
  db.Auth.instance.saveCodeVerifier(codeVerifier);

  return url;
}

/// Returns a [String] with the authorization code from Spotify. If there was an
/// error, [null] will be returned.
Future<String?> requestUserAuth() async {
  const callbackUrlScheme = _redirectUriScheme;
  final state = _getRandomString(12);
  final url = _getAuthUrl(callbackUrlScheme, state);
  try {
    final result = await FlutterWebAuth.authenticate(
        url: url, callbackUrlScheme: callbackUrlScheme);

    final queryResult = Uri.parse(result).queryParameters;
    if (queryResult['error'] != null) {
      throw Exception(
          'There was an error when requesting User Authorization from Spotify:\n${queryResult['error']}');
    }
    if (queryResult['state'] != state) {
      throw Exception(
          'The state returned by the auth does not match the state provided to the auth:\nprovided: $state\nreturned: ${queryResult['state']}');
    }

    return queryResult['code'];
  } catch (e) {
    return null;
  }
}

/// Returns an [AccessToken]  that can be used to send requests to Spotify's WEB
/// API. The method automatically refreshes the access token if needed.
///
/// Before using this function you must request the user's permission with the
/// function [requestUserAuth] which is the [authCode].
/// You can only pass null as the [authCode] if an access token has already
/// initially been requested.
Future<AccessToken> requestAccessToken(String? authCode) async {
  AccessToken? accessToken = await db.Auth.instance.getAccessToken();

  if (accessToken == null) {
    return await getBrandNewAccessToken(authCode!);
  } else {
    if (accessToken.expiresAt.isBefore(DateTime.now())) {
      // refresh the access token
      final url = Uri.https('accounts.spotify.com', '/api/token');
      final form = {
        'grant_type': 'refresh_token',
        'refresh_token': accessToken.refreshToken,
        'client_id': secrets.spotifyClientId
      };
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

      final response =
          await http.Client().post(url, headers: headers, body: form);

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        final newAccessToken = AccessToken(
            accessToken: json['access_token'],
            tokenType: json['token_type'],
            scope: json['scope'],
            expiresIn: json['expires_in'],
            createdAt: DateTime.now(),
            refreshToken: accessToken.refreshToken);
        await db.Auth.instance.saveAccessToken(newAccessToken);

        return newAccessToken;
      } else if (response.statusCode == 400) {
        authCode = await requestUserAuth();

        return await getBrandNewAccessToken(authCode!);
      } else {
        throw Exception(
            'Response code was not 200, was ${response.statusCode}');
      }
    } else {
      return accessToken;
    }
  }
}

Future<AccessToken> getBrandNewAccessToken(String authCode) async {
  final url = Uri.https('accounts.spotify.com', '/api/token');
  final form = {
    'code': authCode,
    'redirect_uri': '$_redirectUriScheme://callback',
    'grant_type': 'authorization_code',
    'client_id': secrets.spotifyClientId,
    'code_verifier': await db.Auth.instance.getCodeVerifier()
  };
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};

  final response = await http.Client().post(url, headers: headers, body: form);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    final newAccessToken = AccessToken(
        accessToken: json['access_token'],
        tokenType: json['token_type'],
        scope: json['scope'],
        expiresIn: json['expires_in'],
        createdAt: DateTime.now(),
        refreshToken: json['refresh_token']);
    await db.Auth.instance.saveAccessToken(newAccessToken);

    return newAccessToken;
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
