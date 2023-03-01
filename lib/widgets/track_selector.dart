import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/widgets/card_view.dart';
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
        Expanded(child: CardView(itemList: itemList, type: Track)),
      ],
    );
  }

  Future getItemList() async {
    AccessToken accessToken = await spotify_auth.requestAccessToken(null);
    List<Track> totalTrackList =
        await getUserTopItems(accessToken: accessToken, type: Track);

    if (!mounted) return null;
    if (context.read<SetupForm>().totalTrackList.isEmpty) {
      context.read<SetupForm>().addAllToTotalTrackList(totalTrackList);
    }

    bool selectedListIsOriginallyEmpty =
        context.read<SetupForm>().selectedTrackList.isEmpty;
    List<Track> newItemList = [];
    for (int i = 0; i < totalTrackList.length; i++) {
      if (i <= 2 && selectedListIsOriginallyEmpty) {
        context.read<SetupForm>().addToSelectedTrackList(totalTrackList[i]);
      }
      newItemList.add(totalTrackList[i]);
    }

    setState(() => itemList = newItemList);

    if (!mounted) return;
    context.read<SetupForm>().setFinishedStep(true);
  }
}
