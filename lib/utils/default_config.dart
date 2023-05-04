import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/utils/get_artists_from_tracks.dart';

/// Returns a [List] of [Track] from top global 50 songs on Spotify.
Future<List<Track>> getDefaultTracks(AccessToken accessToken) async {
  String playlistID = '37i9dQZEVXbMDoHDwVN2tF';

  return await getPlaylistTracks(
      accessToken: accessToken, playlistID: playlistID);
}

/// Returns a [List] of [Artist] from top global 50 songs on Spotify.
///
/// If you have already requested [getDefaultTracks] you can use
/// [getPlaylistTracks] on that function's request.
Future<List<Artist>> getDefaultArtists(AccessToken accessToken) async {
  String playlistID = '37i9dQZEVXbMDoHDwVN2tF';

  return getArtistsFromTracks(await getPlaylistTracks(
      accessToken: accessToken, playlistID: playlistID));
}

/// Returns a [List] of [String] of the top 3 genres.
List<String> getDefaultGenres() {
  return ['pop', 'rock', 'hip-hop'];
}
