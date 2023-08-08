import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/card_view_widget.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/utils/default_config.dart';
import 'package:daily_spotify/styles.dart';

class TrackSelector extends StatefulWidget {
  const TrackSelector({super.key});

  @override
  State<TrackSelector> createState() => _TrackSelectorState();
}

class _TrackSelectorState extends State<TrackSelector> {
  List<Track> itemList = [];

  @override
  void initState() {
    super.initState();

    getItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pick your top three favorite songs',
          textAlign: TextAlign.center,
          style: Styles().subtitleText,
        ),
        FutureBuilder(
            future: getItemList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('An error has occurred, ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return Expanded(
                      child: CardView(itemList: snapshot.data!, type: Track));
                }
              }

              return const LoadingIndicator(text: 'Finding your top songs...');
            }),
      ],
    );
  }

  Future<List<Track>?> getItemList() async {
    AccessToken accessToken = await requestAccessTokenWithoutAuthCode(context);
    List<Track> trackList =
        await getUserTopItems(accessToken: accessToken, type: Track);

    if (trackList.isEmpty) {
      trackList = await getUserTopItems(
          accessToken: accessToken, type: Track, timeRange: 'short_term');
    }
    // get tracks from top global 50 songs on Spotify
    if (trackList.isEmpty) {
      trackList = await getDefaultTracks(accessToken);
    }

    if (!mounted) return null;
    bool initiallyEmpty = context.read<SetupForm>().totalTrackList.isEmpty;

    List<Track> savedTracks = await db.Config.instance.getTrackConfig();
    if (savedTracks.isNotEmpty) {
      if (!mounted) return null;

      for (Track track in savedTracks) {
        context.read<SetupForm>().addToSelectedTrackList(track);

        trackList.removeWhere((element) => element.id == track.id);
      }

      if (initiallyEmpty) {
        context.read<SetupForm>().addAllToTotalTrackList(savedTracks);
      }
    }

    if (!mounted) return null;
    if (initiallyEmpty) {
      context.read<SetupForm>().addAllToTotalTrackList(trackList);
    }

    if (!mounted) return null;
    bool initialSelectedTracksExist =
        context.read<SetupForm>().selectedTrackList.isNotEmpty;
    List<Track> totalTrackList = context.read<SetupForm>().totalTrackList;

    if (!initialSelectedTracksExist) {
      for (int i = 0;
          i < (totalTrackList.length < 3 ? totalTrackList.length : 3);
          i++) {
        Track track = totalTrackList[i];

        // add remaining tracks if needed to get 3 selected tracks
        context.read<SetupForm>().addToSelectedTrackList(track);
      }
    }

    return totalTrackList;
  }
}
