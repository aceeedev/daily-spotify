import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/utils/get_recommendation_seeds.dart';

/// Returns a new unique [DailyTrack]. Also saves the daily track to the
/// database.
///
/// Takes in the parameter [today] which is a [DateTime] and is used as the date
/// of the daily track.
Future<DailyTrack> getNewDailyTrack(DateTime today) async {
  // generate new recommendations
  AccessToken accessToken = await requestAccessToken(null);
  List<Artist> initialSeedArtists = await db.Config.instance.getArtistConfig();
  List<String> initialSeedGenres = await db.Config.instance.getGenreConfig();
  List<Track> initialSeedTracks = await db.Config.instance.getTrackConfig();

  Map<String, dynamic> seeds = await getRecommendationSeeds(
      initialSeedArtists, initialSeedGenres, initialSeedTracks);

  Recommendation recommendation = await getRecommendations(
      accessToken: accessToken,
      seedArtists: seeds['seedArtists'] as List<Artist>,
      seedGenres: seeds['seedGenres'] as List<String>,
      seedTracks: seeds['seedTracks'] as List<Track>,
      maxPopularity: 75);

  // make sure recommendation hasn't been recommended before
  List<Track> allPastTracks = (await db.Tracks.instance.getAllDailyTracks())
      .map((e) => e.track)
      .toList();
  for (Track track in recommendation.tracks) {
    if (!allPastTracks.contains(track)) {
      DailyTrack newDailyTrack = DailyTrack(date: today, track: track);
      await db.Tracks.instance.saveDailyTrack(newDailyTrack);

      return newDailyTrack;
    }
  }

  throw Exception('No track was able to be generated');
}
