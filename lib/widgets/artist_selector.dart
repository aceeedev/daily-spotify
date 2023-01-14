import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/widgets/card_view.dart';
import 'package:daily_spotify/styles.dart';

class ArtistSelector extends StatefulWidget {
  const ArtistSelector({super.key});

  @override
  State<ArtistSelector> createState() => _ArtistSelectorState();
}

class _ArtistSelectorState extends State<ArtistSelector> {
  List<Artist> itemList = [];

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
          'Pick your top three favorite artists',
          textAlign: TextAlign.center,
          style: Styles().subtitleText,
        ),
        Expanded(child: CardView(itemList: itemList, type: Artist)),
      ],
    );
  }

  void getItemList() async {
    List<Artist> totalArtistList = context.read<SetupForm>().totalArtistList;

    // check to make sure artist list was already generated from genre selector
    if (totalArtistList.isEmpty) {
      AccessToken accessToken = await spotify_auth.requestAccessToken(null);

      totalArtistList =
          await getUserTopItems(accessToken: accessToken, type: Artist);
    }

    List<Artist> newItemList = [];
    for (int i = 0; i < totalArtistList.length; i++) {
      if (i <= 2) {
        if (!mounted) return;
        context.read<SetupForm>().addToSelectedArtistList(totalArtistList[i]);
      }
      newItemList.add(totalArtistList[i]);
    }

    setState(() => itemList = newItemList);
    if (!mounted) return;
    context.read<SetupForm>().setFinishedStep(true, notify: false);
  }
}
