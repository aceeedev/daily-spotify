import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a [List] of items of type [type] searched from Spotify's engine
/// where [term] is what is searched.
///
/// You must provide an [accessToken].
///
/// Currently only supports searching for types [Artist] and [Track].
///
/// [Spotify API Docs](https://developer.spotify.com/documentation/web-api/reference/search)
Future<dynamic> searchForItem({
  required AccessToken accessToken,
  required Type type,
  required String term,
  int limit = 20,
  int offset = 0,
}) async {
  final queryParameters = {
    'q': term,
    'type': type == Artist
        ? 'artist'
        : type == Track
            ? 'track'
            : '',
    'limit': limit,
    'offset': offset,
  }.map((key, value) => MapEntry(key, value.toString()));
  final url = Uri.https('api.spotify.com', '/v1/search', queryParameters);
  final headers = {
    'Authorization': 'Bearer ${accessToken.accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.Client().get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (type == Track) {
      List<Track> tracksList = [];

      for (Map<String, dynamic> item in json['tracks']['items']) {
        tracksList.add(Track(
            id: item['id'],
            name: item['name'],
            uri: item['uri'],
            spotifyHref: item['external_urls']['spotify'],
            artists: (item['artists'] as List<dynamic>)
                .map((e) => Artist(
                    id: e['id'],
                    name: e['name'],
                    uri: e['uri'],
                    spotifyUrl: e['external_urls']['spotify']))
                .toList(),
            images: (item['album']['images'] as List<dynamic>)
                .map((e) => SpotifyImage(
                    height: e['height'], url: e['url'], width: e['width']))
                .toList()));
      }

      return tracksList;
    } else if (type == Artist) {
      List<Artist> artistsList = [];

      for (Map<String, dynamic> item in json['artists']['items']) {
        artistsList.add(Artist(
            id: item['id'],
            name: item['name'],
            uri: item['uri'],
            spotifyUrl: item['external_urls']['spotify'],
            images: (item['images'] as List<dynamic>)
                .map((e) => SpotifyImage(
                    height: e['height'], url: e['url'], width: e['width']))
                .toList(),
            genres: (item['genres'] as List).map((e) => e as String).toList()));
      }

      return artistsList;
    }
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
