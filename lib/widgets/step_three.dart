import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/widgets/card_view.dart';

class StepThree extends StatefulWidget {
  const StepThree({super.key});

  @override
  State<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends State<StepThree> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Step Three'),
        const Text('Now pick your top three favorite artists.'),
        const Text(
            'If you don\'t know what artists to pick, just continue to the next step, you can always change these settings later.'),
        Expanded(child: CardView(itemList: getItemList(), type: Artist)),
      ],
    );
  }

  List<Artist> getItemList() {
    List<Artist> totalArtistList = context.read<SetupForm>().totalArtistList;

    List<Artist> itemList = [];
    for (int i = 0; i < totalArtistList.length; i++) {
      if (i <= 2) {
        context.read<SetupForm>().addToSelectedArtistList(totalArtistList[i]);
      }
      itemList.add(totalArtistList[i]);
    }

    return itemList;
  }
}
