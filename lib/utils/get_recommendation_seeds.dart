import 'dart:math';

import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns curated [Future<Map<String, dynamic>>] of the recommendation seeds
/// to be used in [getRecommendations].
///
/// The key value pairs are as follows:
/// 'seedArtists': List<Artists>
/// 'seedGenres': List<String>
/// 'seedTracks': List<Track>
Future<Map<String, List<dynamic>>> getRecommendationSeeds(
    List<Artist> artistList,
    List<String> genreList,
    List<Track> trackList) async {
  Map<String, List<dynamic>> seedMap = {};

  seedMap['seedArtists'] = [randomElement(artistList)].cast<Artist>();
  seedMap['seedGenres'] = [randomElement(genreList)].cast<String>();
  seedMap['seedTracks'] = [randomElement(trackList)].cast<Track>();

  return seedMap;
}

dynamic randomElement(List<dynamic> list) {
  if (list.isEmpty) {
    throw Exception(
        'The list is empty and therefore cannot have a random element.');
  }
  return list[Random().nextInt(list.length)];
}
