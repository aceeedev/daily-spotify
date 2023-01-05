import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/widgets/card_view.dart';

class StepFour extends StatefulWidget {
  const StepFour({super.key});

  @override
  State<StepFour> createState() => _StepFourState();
}

class _StepFourState extends State<StepFour> {
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
        const Text(
          'pick your top three favorite songs',
          textAlign: TextAlign.center,
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
    context.read<SetupForm>().addAllToTotalTrackList(totalTrackList);

    List<Track> newItemList = [];
    for (int i = 0; i < totalTrackList.length; i++) {
      if (i <= 2) {
        context.read<SetupForm>().addToSelectedTrackList(totalTrackList[i]);
      }
      newItemList.add(totalTrackList[i]);
    }

    setState(() => itemList = newItemList);

    if (!mounted) return;
    context.read<SetupForm>().setFinishedStep(true);
  }
}
