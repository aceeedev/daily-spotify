import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/utils/get_recommendation_seeds.dart';
import 'package:daily_spotify/utils/get_new_daily_track.dart';

/// A widget that contains developer settings.
///
/// Should NEVER be apart of the release version of the app.
class DeveloperSettingsWidgets extends StatelessWidget {
  const DeveloperSettingsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) return const SizedBox.shrink();

    return Column(
      children: [
        TextButton(
            onPressed: () async => generateANewRecommendation(context),
            child: const Text('Generate a new recommendation')),
        TextButton(
            onPressed: () async => generateNewDailyTracks(context),
            child: const Text('Generate new daily tracks')),
        TextButton(
            onPressed: () async => deleteAllDailyTracks(),
            child: const Text('Delete all daily tracks')),
        TextButton(
            onPressed: () async => getDailyTrackInfo(),
            child: const Text('Get daily track info')),
        TextButton(
            onPressed: () async => deleteTodaysDailyTrack(),
            child: const Text('Delete today\'s daily track')),
      ],
    );
  }

  Future generateANewRecommendation(BuildContext context) async {
    AccessToken accessToken = await requestAccessTokenWithoutAuthCode(context);
    List<Artist> initialSeedArtists =
        await db.Config.instance.getArtistConfig();
    List<String> initialSeedGenres = await db.Config.instance.getGenreConfig();
    List<Track> initialSeedTracks = await db.Config.instance.getTrackConfig();

    Map<String, dynamic> seeds = await getRecommendationSeeds(
        context, initialSeedArtists, initialSeedGenres, initialSeedTracks);

    Recommendation recommendation = await getRecommendations(
        accessToken: accessToken,
        seedArtists: seeds['seedArtists'] as List<Artist>,
        seedGenres: seeds['seedGenres'] as List<String>,
        seedTracks: seeds['seedTracks'] as List<Track>,
        maxPopularity: 75);

    print('${recommendation.tracks.length} Recommendations');
    print('genre seeds: ${seeds['seedGenres']}');
    print(
        'artist seeds: ${(seeds['seedArtists'] as List<Artist>).map((e) => e.name).toList().join(', ')}');
    print(
        'track seeds: ${(seeds['seedTracks'] as List<Track>).map((e) => e.name).toList().join(', ')}');
    print(recommendation.tracks.first.name);
    print(recommendation.tracks.first.getArtists());
    print('\n');
  }

  Future generateNewDailyTracks(BuildContext context) async {
    int numOfDailyTracksToGenerate = 50;
    int millisecondDelay = 500;

    DateTime date = DateTime.now();
    int i = 0;
    int daysBetweenGaps = 1;
    print(
        'generating daily tracks... (estimated ${numOfDailyTracksToGenerate * millisecondDelay * 0.001} seconds)');
    while (i < numOfDailyTracksToGenerate) {
      if (Random().nextBool()) {
        date = date.add(Duration(days: daysBetweenGaps));

        // delay for too many requests
        await Future.delayed(Duration(milliseconds: millisecondDelay));
        await getNewDailyTrack(context, date);

        daysBetweenGaps = 1;
        i++;
      } else {
        daysBetweenGaps++;
      }
    }

    print('finished generating $numOfDailyTracksToGenerate daily tracks');
  }

  void deleteAllDailyTracks() async {
    await db.Tracks.instance.deleteAllDailyTracks();

    print('deleted all daily tracks');
  }

  void getDailyTrackInfo() async {
    List<DailyTrack> allDailyTracks =
        await db.Tracks.instance.getAllDailyTracks();

    for (DailyTrack dailyTrack in allDailyTracks) {
      print(
          '${DateFormat.yMd().format(dailyTrack.date)} - ${dailyTrack.track.name}');
    }

    print('Total daily tracks: ${allDailyTracks.length}');
  }

  void deleteTodaysDailyTrack() async {
    await db.Tracks.instance.deleteDailyTrack(DateTime.now());
  }
}
