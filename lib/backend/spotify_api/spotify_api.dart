import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:daily_spotify/secrets.dart' as secrets;
import 'package:flutter_web_auth/flutter_web_auth.dart';

const _redirectUriScheme = 'com.example.daily-spotify';

String _getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

String _getAuthPKCEUrl(String redirectUri, String state) {
  const scope = 'user-top-read user-read-recently-played';
  redirectUri += '://';
  final codeVerifier = _getRandomString(100);
  final codeChallenge = sha256
      .convert(utf8.encode(codeVerifier))
      .toString(); // codeVerifier hashed with SHA256

  final queryParameters = {
    'response_type': 'code',
    'client_id': secrets.spotifyClientId,
    'scope': scope,
    'redirect_uri': redirectUri,
    'state': state,
    //'code_challenge_method': 'S256',
    //'code_challenge': codeChallenge
  };

  final url = Uri.https('accounts.spotify.com', '/authorize', queryParameters)
      .toString();

  // save codeVerifier

  return url;
}

/// Returns a String with the authorization code from Spotify
Future<String?> requestUserAuthWithPKCE() async {
  const callbackUrlScheme = _redirectUriScheme;
  final state = _getRandomString(12);
  final url = _getAuthPKCEUrl(callbackUrlScheme, state);
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
}

/// Returns a String with an access token that can be used to send requests to
/// Spotify's WEB API. The method automatically refreshes the access token if
/// needed.
///
/// Before using this method you must request the user's permission with the
/// method [requestUserAuthWithPKCE]
Future<String?> requestAccessToken(String authCode) async {
  final url = Uri.https('accounts.spotify.com', '/api/token');
  final form = {
    'code': authCode,
    'redirect_uri': '$_redirectUriScheme://',
    'grant_type': 'authorization_code',
    'client_id': secrets.spotifyClientId,
    'code_verifier': ''
  };

  final response = await http.Client().post(url, body: form);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw Exception('Error: ${json['error']}');
    }
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
