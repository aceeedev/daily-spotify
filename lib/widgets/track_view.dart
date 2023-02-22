import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/models/daily_track.dart';

/// Returns a widget of a stylized track view.
/// Requires
class TrackView extends StatelessWidget {
  const TrackView(
      {super.key,
      required this.header,
      required this.dailyTrack,
      required this.track,
      required this.averageColorOfImage});
  final Widget header;
  final DailyTrack dailyTrack;
  final Track track;
  final Color averageColorOfImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [
            0.0,
            0.3,
            0.4,
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
            header,
            Padding(
                padding: const EdgeInsets.only(bottom: 75.0),
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
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () async =>
                            await openSong(track.spotifyHref),
                        icon: Icon(Icons.play_circle,
                            color: Styles().mainColor, size: 72.0)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 72.0),
                        child: IconButton(
                            onPressed: () async {
                              ShareResult result = await Share.shareWithResult(
                                  'My pitch of ${DateFormat('MMM d').format(dailyTrack.date)}\n${track.spotifyHref}');

                              if (result.status ==
                                  ShareResultStatus.dismissed) {
                                final snackBar = SnackBar(
                                  content: const Text(
                                      'Don\'t be shy, share the love, share the music'),
                                  backgroundColor: averageColorOfImage,
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            icon: Icon(Icons.share,
                                color: Styles().mainColor, size: 24.0)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future openSong(String spotifyHref) async {
    Uri url = Uri.parse(spotifyHref);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
