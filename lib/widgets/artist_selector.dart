import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/widgets/card_view.dart';

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
        const Text(
          'Pick your top three favorite artists',
          textAlign: TextAlign.center,
        ),
        Expanded(child: CardView(itemList: itemList, type: Artist)),
      ],
    );
  }

  void getItemList() {
    List<Artist> totalArtistList = context.read<SetupForm>().totalArtistList;

    List<Artist> newItemList = [];
    for (int i = 0; i < totalArtistList.length; i++) {
      if (i <= 2) {
        context.read<SetupForm>().addToSelectedArtistList(totalArtistList[i]);
      }
      newItemList.add(totalArtistList[i]);
    }

    setState(() => itemList = newItemList);
    context.read<SetupForm>().setFinishedStep(true, notify: false);
  }
}
