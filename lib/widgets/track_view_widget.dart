import 'dart:io' show Platform;
import 'package:daily_spotify/pages/home_page.dart';
import 'package:daily_spotify/utils/get_new_daily_track.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appcheck/appcheck.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/models/daily_track.dart';
import 'package:daily_spotify/providers/track_view_provider.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Returns a widget of a stylized track view.
/// Requires [header], a widget, [dailyTrack], a [DailyTrack], [track], a
/// [Track], and [averageColorOfImage], a Color.
class TrackView extends StatelessWidget {
  TrackView(
      {super.key,
      required this.header,
      required this.dailyTrack,
      required this.track,
      required this.averageColorOfImage});
  final Widget header;
  final DailyTrack dailyTrack;
  final Track track;
  final Color averageColorOfImage;

  static const List<int> flexValues = [6, 46, 20, 7];
  static const List<String> emojiOptions = ['😮', '🔥', '❤️', '💃', '🕺'];

  final GlobalKey openInSpotifyKey = GlobalKey();
  final GlobalKey artistTextKey = GlobalKey();

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
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              header,
              Expanded(
                flex: flexValues[0],
                child: Text(
                    'Your ${dailyTrack.reaction == null ? '' : '${dailyTrack.reaction} '}song of ${DateFormat('MMM d').format(dailyTrack.date)}',
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
                      key: artistTextKey,
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
                  key: openInSpotifyKey,
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
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 75.0, left: 72.0, right: 72.0),
                child: _IconButtonRow(
                  dailyTrack: dailyTrack,
                  track: track,
                  averageColorOfImage: averageColorOfImage,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: openInSpotifyKey.currentContext != null ||
                        artistTextKey.currentContext != null
                    ? (((openInSpotifyKey.currentContext!.findRenderObject()
                                        as RenderBox)
                                    .localToGlobal(Offset.zero)
                                    .dy +
                                (artistTextKey.currentContext!
                                        .findRenderObject() as RenderBox)
                                    .localToGlobal(Offset.zero)
                                    .dy) /
                            2) -
                        65
                    : 0),
            child: context.watch<TrackViewProvider>().emojiReactionClicked
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _createEmojiButtons(emojiOptions),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Future openSong(String uri) async {
    Uri url = Uri.parse(uri);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  List<Widget> _createEmojiButtons(List<String> emojis) {
    return emojis
        .map((e) => _EmojiButton(
              emoji: e,
              dailyTrack: dailyTrack,
            ))
        .toList();
  }
}

/// The row of icon buttons for options on the track view.
class _IconButtonRow extends StatelessWidget {
  _IconButtonRow({
    super.key,
    required this.dailyTrack,
    required this.track,
    required this.averageColorOfImage,
  });

  final DailyTrack dailyTrack;
  final Track track;
  final Color averageColorOfImage;

  final double iconSize = 24.0;
  final Color iconColor = Styles().mainColor;

  static const int maxNumberOfReshuffles = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (dailyTrack.timesReshuffled < maxNumberOfReshuffles &&
            dailyTrack.date.isSameDate(DateTime.now()))
          IconButton(
            onPressed: () => _showReshuffleDialog(context),
            icon: Icon(Icons.replay, color: iconColor, size: iconSize),
          ),
        IconButton(
          onPressed: () =>
              context.read<TrackViewProvider>().switchEmojiReactionClicked(),
          icon: Icon(Icons.add_reaction, color: iconColor, size: iconSize),
        ),
        IconButton(
            onPressed: () async {
              ShareResult result = await Share.shareWithResult(
                  'My ${dailyTrack.reaction == null ? '' : '${dailyTrack.reaction} '}pitch of ${DateFormat('MMM d').format(dailyTrack.date)}\n${track.spotifyHref}');

              if (result.status == ShareResultStatus.dismissed) {
                final snackBar = SnackBar(
                  content: const Text(
                      'Don\'t be shy, share the love, share the music'),
                  backgroundColor: averageColorOfImage,
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            icon: Icon(Icons.share, color: iconColor, size: iconSize)),
      ],
    );
  }

  Future<void> _showReshuffleDialog(BuildContext context) async {
    final int numOfTimesUserCanReshuffle =
        maxNumberOfReshuffles - dailyTrack.timesReshuffled;

    const String title = 'Reshuffle?';
    final String content =
        'Warning: you will lose today\'s pitch and you can only reshuffle $numOfTimesUserCanReshuffle more time${numOfTimesUserCanReshuffle > 1 ? 's' : ''}.';
    const String yesText = 'Reshuffle';
    const String noText = 'Never mind';

    return showDialog(
        context: context,
        builder: (BuildContext context) => (Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text(title),
                content: Text(content),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context, true),
                    isDestructiveAction: true,
                    child: const Text(yesText),
                  ),
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(noText),
                  )
                ],
              )
            : AlertDialog(
                backgroundColor: Styles().backgroundColor,
                title: Text(
                  title,
                  style: Styles().subtitleText,
                ),
                content: Text(
                  content,
                  style: Styles().defaultText,
                ),
                actions: <Widget>[
                  TextButton(
                    style: Styles().unselectedElevatedButtonStyle,
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      yesText,
                      style: Styles().defaultText,
                    ),
                  ),
                  TextButton(
                    style: Styles().unselectedElevatedButtonStyle,
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      noText,
                      style: Styles().defaultText,
                    ),
                  ),
                ],
              ))).then((value) async {
      if (value == null) return;

      if (value) {
        await db.Tracks.instance.deleteDailyTrack(dailyTrack.date);

        context
            .read<TrackViewProvider>()
            .addToExcludeTrackList(dailyTrack.track);
        await getNewDailyTrack(
            context: context,
            today: dailyTrack.date,
            numberOfReshuffles: dailyTrack.timesReshuffled + 1,
            excludeTracks: context.read<TrackViewProvider>().excludeTrackList);

        context.read<TrackViewProvider>().setEmojiReactionClicked(false);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()));
      }
    });
  }
}

/// The emoji buttons are used for the reactions menu.
class _EmojiButton extends StatelessWidget {
  const _EmojiButton(
      {super.key, required this.emoji, required this.dailyTrack});
  final String emoji;
  final DailyTrack dailyTrack;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          DailyTrack updatedDailyTrack = dailyTrack;
          updatedDailyTrack.reaction =
              dailyTrack.reaction != emoji ? emoji : null;

          await db.Tracks.instance.saveDailyTrack(updatedDailyTrack);

          context.read<TrackViewProvider>().switchEmojiReactionClicked();
        },
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22.0),
        ));
  }
}
