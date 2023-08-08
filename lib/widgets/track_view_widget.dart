import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appcheck/appcheck.dart';
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

  static const List<int> flexValues = [4, 46, 20, 7];

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
            0.7,
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
            Expanded(
              flex: flexValues[0],
              child: Text(
                  'Your song of ${DateFormat('MMM d').format(dailyTrack.date)}',
                  style: Styles().largeText),
            ),
            Expanded(
              flex: flexValues[1],
              child: Image.network(
                track.images.first.url,
                width: track.images.first.width.toDouble() / 2,
                height: track.images.first.height.toDouble() / 2,
              ),
            ),
            Expanded(
              flex: flexValues[2],
              child: Column(
                children: [
                  Text(
                    track.name,
                    style: Styles().titleText,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  Text(
                    track.getArtists(),
                    style: Styles().subtitleText,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: flexValues[3],
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    String spotiftyAppUri = '';
                    if (Platform.isAndroid) {
                      spotiftyAppUri = 'com.spotify.music';
                    } else if (Platform.isIOS) {
                      spotiftyAppUri = 'spotify://';
                    }

                    // see if Spotifty is installed
                    await AppCheck.checkAvailability(spotiftyAppUri);

                    await openSong(track.uri);
                  } catch (e) {
                    await openSong(track.spotifyHref);
                  }
                },
                style: Styles().unselectedElevatedButtonStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open in ',
                      style: Styles().subtitleText,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Image.asset(
                          'assets/spotify/Spotify_Icon_RGB_Green.png',
                          width: 32,
                          height: 32),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 75.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 72.0),
                  child: IconButton(
                      onPressed: () async {
                        ShareResult result = await Share.shareWithResult(
                            'My pitch of ${DateFormat('MMM d').format(dailyTrack.date)}\n${track.spotifyHref}');

                        if (result.status == ShareResultStatus.dismissed) {
                          final snackBar = SnackBar(
                            content: const Text(
                                'Don\'t be shy, share the love, share the music'),
                            backgroundColor: averageColorOfImage,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      icon: Icon(Icons.share,
                          color: Styles().mainColor, size: 24.0)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future openSong(String uri) async {
    Uri url = Uri.parse(uri);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
