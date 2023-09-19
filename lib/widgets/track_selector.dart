import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/card_view_widget.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/widgets/search_widget.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/utils/default_config.dart';
import 'package:daily_spotify/styles.dart';

class TrackSelector extends StatefulWidget {
  const TrackSelector({super.key});

  @override
  State<TrackSelector> createState() => _TrackSelectorState();
}

class _TrackSelectorState extends State<TrackSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Pick your top three favorite songs',
            textAlign: TextAlign.center,
            style: Styles().subtitleText,
          ),
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
                      child: ListView(
                    children: [
                      if (context
                          .watch<SetupForm>()
                          .selectedTrackList
                          .isNotEmpty) ...[
                        Text(
                          'Selected',
                          textAlign: TextAlign.center,
                          style: Styles().largeText,
                        ),
                        CardView(
                            itemList:
                                context.watch<SetupForm>().selectedTrackList,
                            type: Track),
                      ],
                      Text(
                        'Recommended',
                        textAlign: TextAlign.center,
                        style: Styles().largeText,
                      ),
                      CardView(itemList: snapshot.data!, type: Track),
                      Text(
                        'Search',
                        textAlign: TextAlign.center,
                        style: Styles().largeText,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Search(onSubmit: (searchedTerm) async {
                          AccessToken accessToken =
                              await requestAccessTokenWithoutAuthCode(context);

                          List<Track> searchResults = (await searchForItem(
                              accessToken: accessToken,
                              type: Track,
                              term: searchedTerm)) as List<Track>;

                          if (!mounted) return;
                          context
                              .read<SetupForm>()
                              .setSearchedTrackList(searchResults);
                        }),
                      ),
                      if (context
                          .watch<SetupForm>()
                          .searchedTrackList
                          .isNotEmpty)
                        CardView(
                            itemList:
                                context.watch<SetupForm>().searchedTrackList,
                            type: Track),
                      if (context.watch<SetupForm>().searchedTrackList.isEmpty)
                        Text(
                          'No results',
                          style: Styles().subtitleText,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ));
                }
              }

              return const Expanded(
                  child: LoadingIndicator(text: 'Finding your top songs...'));
            }),
      ],
    );
  }

  Future<List<Track>?> getItemList() async {
    AccessToken accessToken = await requestAccessTokenWithoutAuthCode(context);

    List<Track> trackList =
        await getUserTopItems(accessToken: accessToken, type: Track);

    // get tracks from top global 50 songs on Spotify if needed
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

    List<Track> totalTrackList = context.read<SetupForm>().totalTrackList;

    return totalTrackList;
  }
}
