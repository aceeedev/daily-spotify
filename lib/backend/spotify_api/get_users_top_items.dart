import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/models/access_token.dart';
import 'package:daily_spotify/backend/spotify_api/models/track.dart';
import 'package:daily_spotify/backend/spotify_api/models/artist.dart';
import 'package:daily_spotify/backend/spotify_api/models/spotify_image.dart';

/// Returns a [List] of the the top [limit] tracks or albums for the authorized
/// user depending on the [type] parameter of the authorized user.
///
/// You must provide an [accessToken]
Future<dynamic> getUserTopItems(
    {required AccessToken accessToken,
    required String type,
    int limit = 20,
    int offset = 0,
    String timeRange = 'medium_term'}) async {
  final queryParameters = {
    'limit': limit,
    'offset': offset,
    'time_range': timeRange
  }.map((key, value) => MapEntry(key, value.toString()));
  final url = Uri.https('api.spotify.com', '/v1/me/top/$type', queryParameters);
  final headers = {
    'Authorization': 'Bearer ${accessToken.accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.Client().get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (type == 'tracks') {
      List<Track> tracksList = [];

      for (Map<String, dynamic> item in json['items']) {
        List<Artist> artists = [];
        for (Map<String, dynamic> artist in json['artists']) {
          artists.add(Artist(
              id: artist['id'],
              name: artist['name'],
              uri: artist['uri'],
              spotifyUrl: artist['external_urls']['spotify']));
        }

        List<SpotifyImage> images = [];
        for (Map<String, dynamic> image in json['images']) {
          images.add(SpotifyImage(
              height: image['height'],
              url: image['url'],
              width: image['width']));
        }

        tracksList.add(Track(
            id: item['id'],
            name: item['name'],
            uri: item['uri'],
            artists: artists,
            images: images));
      }

      return tracksList;
    } else if (type == 'artists') {
      List<Artist> artistsList = [];

      for (Map<String, dynamic> item in json['items']) {
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
