import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a [List] of [Track] from a specified playlist.
/// [getRecommendations].
///
/// You must provide an [accessToken].
///
/// This is a custom function that uses Spotify's Get Playlist endpoint
///
/// [Spotify API Docs](https://developer.spotify.com/documentation/web-api/reference/get-playlist)
Future<List<Track>> getPlaylistTracks(
    {required AccessToken accessToken, required String playlistID}) async {
  final url = Uri.https('api.spotify.com', '/v1/playlists/$playlistID');
  final headers = {
    'Authorization': 'Bearer ${accessToken.accessToken}',
    'Content-Type': 'application/json'
  };
  final response = await http.Client().get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    List<Track> tracksList = [];
    for (Map<String, dynamic> item in json['tracks']['items']) {
      Map<String, dynamic> track = item['track'];

      tracksList.add(Track(
          id: track['id'],
          name: track['name'],
          uri: track['uri'],
          spotifyHref: track['external_urls']['spotify'],
          artists: (track['artists'] as List<dynamic>)
              .map((e) => Artist(
                  id: e['id'],
                  name: e['name'],
                  uri: e['uri'],
                  spotifyUrl: e['external_urls']['spotify']))
              .toList(),
          images: (track['album']['images'] as List<dynamic>)
              .map((e) => SpotifyImage(
                  height: e['height'], url: e['url'], width: e['width']))
              .toList()));
    }

    return tracksList;
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
