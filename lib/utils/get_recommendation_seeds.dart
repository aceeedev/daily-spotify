import 'dart:math';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import './filter_by_genre.dart';

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
  // 0: artist, 1: genre, 2: track
  int getMoreRecent = Random().nextInt(3);

  List<Artist> seedArtists = [];
  List<String> seedGenres = [];
  List<Track> seedTracks = [];

  AccessToken accessToken = await requestAccessToken(null);

  // artist seed
  if (getMoreRecent == 0) {
    List<Artist> artistList = await getUserTopItems(
        accessToken: accessToken, type: Artist, timeRange: 'short_term');

    seedArtists.add(artistList.first);
  } else {
    seedArtists.add(randomElement(artistList));
  }

  // genre seed
  if (getMoreRecent == 1) {
    List<Artist> artistList = await getUserTopItems(
        accessToken: accessToken, type: Artist, timeRange: 'short_term');

    List<String> genreList =
        (await filterByGenre(accessToken, artistList)).keys.toList();

    seedGenres.add(genreList.first);
  } else {
    seedGenres.add(randomElement(genreList));
  }

  // track seed
  List<Track> trackList = await getUserTopItems(
      accessToken: accessToken, type: Track, timeRange: 'short_term');

  if (getMoreRecent == 2) {
    seedTracks = trackList.sublist(0, 2);
  } else {
    seedTracks.add(trackList.first);
    seedTracks.add(randomElement(trackList));
  }

  return {
    'seedArtists': seedArtists,
    'seedGenres': seedGenres,
    'seedTracks': seedTracks,
  };
}

dynamic randomElement(List<dynamic> list) {
  if (list.isEmpty) {
    throw Exception(
        'The list is empty and therefore cannot have a random element.');
  }
  return list[Random().nextInt(list.length)];
}
