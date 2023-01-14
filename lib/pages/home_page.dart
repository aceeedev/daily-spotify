import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/pages/calendar_page.dart';
import 'package:daily_spotify/pages/settings_page.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/brand_text.dart';
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

                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0.0,
                            0.2,
                            0.3,
                            0.8,
                          ],
                          colors: [
                            Styles().backgroundColor,
                            averageColorOfImage,
                            averageColorOfImage,
                            Styles().backgroundColor
                          ],
                        )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
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
                            Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                    'Your song of ${DateFormat('MMM d').format(dailyTrack.date)}',
                                    style: Styles().largeText)),
                            Image.network(
                              track.images.first.url,
                              width: track.images.first.width.toDouble() / 2,
                              height: track.images.first.height.toDouble() / 2,
                            ),
                            Text(
                              track.name,
                              style: Styles().titleText,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              track.getArtists(),
                              style: Styles().subtitleText,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                }
                return const Center(child: CircularProgressIndicator());
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
        seedTracks: seeds['seedTracks'] as List<Track>);

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

  Future<Color> getAverageColor(String imageUrl) async {
    http.Response response = await http.get(
      Uri.parse(imageUrl),
    );
    img.Image? bitmap = img.decodeImage(response.bodyBytes);

    int redBucket = 0;
    int greenBucket = 0;
    int blueBucket = 0;
    int pixelCount = 0;

    for (int y = 0; y < bitmap!.height; y++) {
      for (int x = 0; x < bitmap.width; x++) {
        final pixel = bitmap.getPixel(x, y);

        pixelCount++;
        redBucket += pixel.r as int;
        greenBucket += pixel.g as int;
        blueBucket += pixel.b as int;
      }
    }

    return Color.fromRGBO(redBucket ~/ pixelCount, greenBucket ~/ pixelCount,
        blueBucket ~/ pixelCount, 1);
  }
}
