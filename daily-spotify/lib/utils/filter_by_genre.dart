import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a map of genres sorted in descending order that can be used by
/// [getRecommendations].
///
/// You must provide an [accessToken] and [artistList]. The genres are collected
/// from [artistList].
Future<Map<String, int>> filterByGenre(
    AccessToken accessToken, List<Artist> artistList) async {
  Map<String, int> genresMap = {};
  for (Artist artist in artistList) {
    artist.genres!.toList().forEach((genre) {
      if (genresMap[genre] == null) {
        genresMap[genre] = 1;
      } else {
        genresMap[genre] = genresMap[genre]! + 1;
      }
    });
  }

  // remove genres that are not able to be used as a recommendation
  List<String> availableSeedGenres =
      await getAvailableGenreSeeds(accessToken: accessToken);

  genresMap =
      genresMap.map((key, value) => MapEntry(key.replaceAll(' ', '-'), value));
  genresMap.removeWhere((key, value) => !availableSeedGenres.contains(key));

  // sort by descending value of number of times it appears in an artist
  genresMap = Map.fromEntries(genresMap.entries.toList()
    ..sort((e1, e2) => e2.value.compareTo(e1.value)));

  return genresMap;
}
