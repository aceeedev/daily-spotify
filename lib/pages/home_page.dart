import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/track_view_provider.dart';
import 'package:daily_spotify/pages/calendar_page.dart';
import 'package:daily_spotify/pages/settings_page.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/widgets/custom_scaffold.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/brand_text_widget.dart';
import 'package:daily_spotify/widgets/track_view_widget.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/utils/get_new_daily_track.dart';
import 'package:daily_spotify/utils/get_average_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: Frame(
            customPadding: const EdgeInsets.all(0.0),
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
                        header: Padding(
                          padding: const EdgeInsets.only(
                              right: 10.0, left: 10.0, top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => pushToNewPage(
                                    context, const CalendarPage()),
                                icon: Icon(
                                  Icons.calendar_month,
                                  color: Styles().mainColor,
                                  size: iconSize,
                                ),
                              ),
                              const BrandText(),
                              IconButton(
                                onPressed: () => pushToNewPage(
                                    context, const SettingsPage()),
                                icon: Icon(
                                  Icons.settings,
                                  color: Styles().mainColor,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        dailyTrack: dailyTrack,
                        track: track,
                        averageColorOfImage: averageColorOfImage);
                  }
                }
                return const LoadingIndicator(
                    text: 'Generating your curated daily song...');
              },
              future: getDailyTrack(),
            )));
  }

  /// Returns a [Future<Map<String, dynamic>>] which contains the values,
  /// ['dailyTrack'] and ['averageColorOfImage']
  Future<Map<String, dynamic>?> getDailyTrack() async {
    // check if daily track has already been generated
    DateTime now = DateTime.now();
    DailyTrack? dailyTrack = await db.Tracks.instance.getDailyTrack(now);
    if (dailyTrack != null) {
      Color averageColor =
          await getAverageColor(dailyTrack.track.images.last.url);

      return {'dailyTrack': dailyTrack, 'averageColorOfImage': averageColor};
    }

    if (!mounted) return null;
    DailyTrack? newDailyTrack;
    while (newDailyTrack == null) {
      newDailyTrack = await getNewDailyTrack(
          context: context, today: now, numberOfReshuffles: 0);
    }
    Color averageColor =
        await getAverageColor(newDailyTrack.track.images.last.url);

    return {'dailyTrack': newDailyTrack, 'averageColorOfImage': averageColor};
  }

  void pushToNewPage(BuildContext context, Widget page) {
    context.read<TrackViewProvider>().setEmojiReactionClicked(false);

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
