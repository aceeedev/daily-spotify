import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// Returns a [List] of [Artist] from the provided [List] of [Track].
List<Artist> getArtistsFromTracks(List<Track> trackList) {
  Set<Artist> artistSet = {};
  Set<String> idSet = {};
  for (Track track in trackList) {
    for (Artist artist in track.artists) {
      if (idSet.add(artist.id)) {
        artistSet.add(artist);
      }
    }
  }

  return artistSet.toList();
}
