import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a [List] of recommend tracks based on the seed.
/// Does not include the min and max parameters the Spotify API provides.
///
/// You must provide an [accessToken], [seedArtists], [seedGenres], and
/// [seedTracks].
Future<Recommendation> getRecommendations({
  required AccessToken accessToken,
  required List<Artist> seedArtists,
  required List<String> seedGenres,
  required List<Track> seedTracks,
  int limit = 20,
  String? market,
  double? targetAcousticness,
  double? targetDanceability,
  int? targetDurationMs,
  double? targetEnergy,
  double? targetInstrumentalness,
  int? targetKey,
  double? targetLiveness,
  double? targetLoudness,
  int? targetMode,
  int? targetPopularity,
  double? targetSpeechiness,
  double? targetTempo,
  int? targetTimeSignature,
  double? targetValence,
}) async {
  if (seedArtists.length + seedGenres.length + seedTracks.length > 5) {
    throw Exception(
        'The total amount of seeds is greater than 5.\nArtists: ${seedArtists.length}, Genres: ${seedGenres.length}, Tracks: ${seedTracks.length}');
  }
  final String commaSeparatedArtists =
      seedArtists.map((e) => e.id).toList().join(',');
  final String commaSeparatedGenres = seedGenres.join(',');
  final String commaSeparatedTracks =
      seedTracks.map((e) => e.id).toList().join(',');

  Map<String, dynamic> queryParameters = {
    'seed_artists': commaSeparatedArtists,
    'seed_genres': commaSeparatedGenres,
    'seed_tracks': commaSeparatedTracks,
    'limit': limit,
    'market': market,
    'target_acousticness': targetAcousticness,
    'target_danceability': targetDanceability,
    'target_duration_ms': targetDurationMs,
    'target_energy': targetEnergy,
    'target_instrumentalness': targetInstrumentalness,
    'target_key': targetKey,
    'target_liveness': targetLiveness,
    'target_loudness': targetLoudness,
    'target_mode': targetMode,
    'target_popularity': targetPopularity,
    'target_speechiness': targetSpeechiness,
    'target_tempo': targetTempo,
    'target_time_signature': targetTimeSignature,
    'target_valence': targetValence,
  };
  queryParameters.removeWhere((key, value) => value == null);
  queryParameters =
      queryParameters.map((key, value) => MapEntry(key, value.toString()));

  final url =
      Uri.https('api.spotify.com', '/v1/recommendations', queryParameters);
  final headers = {
    'Authorization': 'Bearer ${accessToken.accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.Client().get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    List<Seeds> seedsList = [];
    for (Map<String, dynamic> item in json['seeds']) {
      seedsList.add(Seeds(
          afterFilteringSize: item['afterFilteringSize'],
          afterRelinkingSize: item['afterRelinkingSize'],
          href: item['href'],
          id: item['id'],
          initialPoolSize: item['initialPoolSize'],
          type: item['type']));
    }

    List<Track> tracksList = [];
    for (Map<String, dynamic> item in json['tracks']) {
      tracksList.add(Track(
          id: item['id'],
          name: item['name'],
          uri: item['uri'],
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

    return Recommendation(seeds: seedsList, tracks: tracksList);
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
