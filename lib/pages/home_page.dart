import 'package:daily_spotify/main.dart';
import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/pages/calendar_page.dart';
import 'package:daily_spotify/pages/settings_page.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/brand_text.dart';
import 'package:daily_spotify/widgets/track_view.dart';
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/utils/get_recommendation_seeds.dart';
import 'package:daily_spotify/utils/get_average_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Frame(
            showLogo: false,
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('An error has occurred, ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    DailyTrack dailyTrack = (snapshot.data
                        as Map<String, dynamic>)['dailyTrack'] as DailyTrack;
                    Track track = dailyTrack.track;

                    Color averageColorOfImage = (snapshot.data
                            as Map<String, dynamic>)['averageColorOfImage']
                        as Color;

                    return TrackView(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CalendarPage())),
                              icon: Icon(
                                Icons.calendar_month,
                                color: Styles().mainColor,
                              ),
                            ),
                            const BrandText(),
                            IconButton(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage())),
                              icon: Icon(
                                Icons.settings,
                                color: Styles().mainColor,
                              ),
                            ),
                          ],
                        ),
                        dailyTrack: dailyTrack,
                        track: track,
                        averageColorOfImage: averageColorOfImage);
                  }
                }
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Text(
                      'Generating your curated daily song...',
                      style: Styles().defaultText,
                    )
                  ],
                ));
              },
              future: getDailyTrack(),
            )));
  }

  /// Returns a [Future<Map<String, dynamic>>] which contains the values,
  /// ['dailyTrack'] and ['averageColorOfImage']
  Future<Map<String, dynamic>> getDailyTrack() async {
    // check if daily track has already been generated
    DateTime now = DateTime.now();
    DailyTrack? dailyTrack = await db.Tracks.instance.getDailyTrack(now);
    if (dailyTrack != null) {
      Color averageColor =
          await getAverageColor(dailyTrack.track.images.last.url);

      return {'dailyTrack': dailyTrack, 'averageColorOfImage': averageColor};
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
        seedTracks: seeds['seedTracks'] as List<Track>,
        maxPopularity: 75);

    // make sure recommendation hasn't been recommended before
    List<Track> allPastTracks = (await db.Tracks.instance.getAllDailyTracks())
        .map((e) => e.track)
        .toList();
    for (Track track in recommendation.tracks) {
      if (!allPastTracks.contains(track)) {
        DailyTrack newDailyTrack = DailyTrack(date: now, track: track);
        db.Tracks.instance.saveDailyTrack(newDailyTrack);

        Color averageColor =
            await getAverageColor(newDailyTrack.track.images.last.url);

        return {
          'dailyTrack': newDailyTrack,
          'averageColorOfImage': averageColor
        };
      }
    }

    throw Exception('No track was able to be generated');
  }
}
