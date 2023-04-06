import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/widgets/card_view_widget.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/styles.dart';

class ArtistSelector extends StatefulWidget {
  const ArtistSelector({super.key});

  @override
  State<ArtistSelector> createState() => _ArtistSelectorState();
}

class _ArtistSelectorState extends State<ArtistSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pick your top three favorite artists',
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
                      child: CardView(itemList: snapshot.data!, type: Artist));
                }
              }

              return const LoadingIndicator(
                  text: 'Finding your top artists...');
            }),
      ],
    );
  }

  Future<List<Artist>?> getItemList() async {
    List<Artist> initialTotalArtistList =
        context.read<SetupForm>().totalArtistList;
    bool initiallyEmpty = initialTotalArtistList.isEmpty;

    // check to make sure artist list was already generated from genre selector
    if (initiallyEmpty) {
      AccessToken accessToken = await spotify_auth.requestAccessToken(null);

      List<Artist> artistList =
          await getUserTopItems(accessToken: accessToken, type: Artist);

      List<Artist> savedArtists = await db.Config.instance.getArtistConfig();
      if (savedArtists.isNotEmpty) {
        if (!mounted) return null;

        for (Artist artist in savedArtists) {
          context.read<SetupForm>().addToSelectedArtistList(artist);

          artistList.removeWhere((element) => element.id == artist.id);
        }

        context.read<SetupForm>().addAllToTotalArtistList(savedArtists);
        context.read<SetupForm>().addAllToTotalArtistList(artistList);
      }
    }

    if (!mounted) return null;
    bool initialSelectedArtistsExist =
        context.read<SetupForm>().selectedArtistList.isNotEmpty;
    List<Artist> totalArtistList = context.read<SetupForm>().totalArtistList;

    if (!initialSelectedArtistsExist) {
      for (int i = 0;
          i < (totalArtistList.length < 3 ? totalArtistList.length : 3);
          i++) {
        Artist artist = totalArtistList[i];

        // add remaining artists if needed to get 3 selected artists
        context.read<SetupForm>().addToSelectedArtistList(artist);
      }
    }

    return totalArtistList;
  }
}
