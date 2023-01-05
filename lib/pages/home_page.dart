import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/utils/get_recommendation_seeds.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Frame(
            child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('An error has occurred, ${snapshot.error}'));
              } else if (snapshot.hasData) {
                DailyTrack dailyTrack = snapshot.data as DailyTrack;
                Track track = dailyTrack.track;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          'Your song of ${DateFormat('MMM d').format(dailyTrack.date)}'),
                      Image.network(
                        track.images[1].url,
                        width: track.images[1].width.toDouble(),
                        height: track.images[1].height.toDouble(),
                      ),
                      Text(track.name),
                      Text(track.getArtists())
                    ],
                  ),
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
          future: getDailyTrack(),
        )));
  }

  Future<DailyTrack> getDailyTrack() async {
    // check if daily track has already been generated
    DateTime now = DateTime.now();
    DailyTrack? dailyTrack = await db.Tracks.instance.getDailyTrack(now);
    if (dailyTrack != null) {
      return dailyTrack;
    }

    // generate new recommendations
    AccessToken accessToken = await requestAccessToken(null);
    List<Artist> initialSeedArtists =
        await db.Config.instance.getArtistConfig();
    List<String> initialSeedGenres = await db.Config.instance.getGenreConfig();
    List<Track> initialSeedTracks = await db.Config.instance.getTrackConfig();

    Map<String, dynamic> seeds = await getRecommendationSeeds(
        initialSeedArtists, initialSeedGenres, initialSeedTracks);

    Recommendation recommendation = await getRecommendations(
        accessToken: accessToken,
        seedArtists: seeds['seedArtists'] as List<Artist>,
        seedGenres: seeds['seedGenres'] as List<String>,
        seedTracks: seeds['seedTracks'] as List<Track>);

    // make sure recommendation hasn't been recommended before
    List<Track> allPastTracks = (await db.Tracks.instance.getAllDailyTracks())
        .map((e) => e.track)
        .toList();
    for (Track track in recommendation.tracks) {
      if (!allPastTracks.contains(track)) {
        DailyTrack newDailyTrack = DailyTrack(date: now, track: track);
        db.Tracks.instance.saveDailyTrack(newDailyTrack);

        return newDailyTrack;
      }
    }

    throw Exception('No track was able to be generated');
  }
}
