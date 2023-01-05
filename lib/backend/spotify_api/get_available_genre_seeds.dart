import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a [List] of [String] genres that can be used as a parameter for
/// [getRecommendations].
///
/// You must provide an [accessToken].
Future<List<String>> getAvailableGenreSeeds(
    {required AccessToken accessToken}) async {
  final url =
      Uri.https('api.spotify.com', '/v1/recommendations/available-genre-seeds');
  final headers = {
    'Authorization': 'Bearer ${accessToken.accessToken}',
    'Content-Type': 'application/json'
  };

  final response = await http.Client().get(url, headers: headers);

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    return json['genres'].cast<String>();
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}
