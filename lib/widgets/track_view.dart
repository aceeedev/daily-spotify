import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
            header,
            Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                    'Your song of ${DateFormat('MMM d').format(dailyTrack.date)}',
                    style: Styles().largeText)),
            GestureDetector(
              onTap: () async {
                Uri url = Uri.parse(track.spotifyHref);

                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
              child: Image.network(
                track.images.first.url,
                width: track.images.first.width.toDouble() / 2,
                height: track.images.first.height.toDouble() / 2,
              ),
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
