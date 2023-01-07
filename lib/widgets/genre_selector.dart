import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/utils/filter_by_genre.dart';
import 'package:daily_spotify/styles.dart';

class GenreSelector extends StatefulWidget {
  const GenreSelector({super.key});

  @override
  State<GenreSelector> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {
  @override
  void initState() {
    super.initState();

    getAndAddGenres();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Pick your top three favorite genres',
            textAlign: TextAlign.center),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              children:
                  getGenreButtons(context.watch<SetupForm>().totalGenreList),
            ),
          ),
        )
      ],
    );
  }

  void getAndAddGenres() async {
    AccessToken accessToken = await spotify_auth.requestAccessToken(null);

    List<Artist> artistList =
        await getUserTopItems(accessToken: accessToken, type: Artist);

    if (!mounted) return;
    context.read<SetupForm>().addAllToTotalArtistList(artistList);

    Map<String, int> genresMap = await filterByGenre(accessToken, artistList);

    if (!mounted) return;
    context.read<SetupForm>().addAllToTotalGenreList(genresMap.keys.toList());
    context.read<SetupForm>().setFinishedStep(true);
  }

  List<Widget> getGenreButtons(List<String> genreList) {
    List<GenreButton> genreButtons = [];

    for (int i = 0; i < genreList.length; i++) {
      String genre = genreList[i];

      // add the top three genres as selected
      if (i <= 2) {
        genreButtons.add(GenreButton(genre: genre, selected: true));
        context.read<SetupForm>().addToSelectedGenreList(genre);
      } else {
        genreButtons.add(GenreButton(genre: genre));
      }
    }

    return genreButtons;
  }
}

class GenreButton extends StatefulWidget {
  GenreButton({super.key, required this.genre, this.selected = false});

  final String genre;
  bool selected;

  @override
  State<GenreButton> createState() => _GenreButtonState();
}

class _GenreButtonState extends State<GenreButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
          onPressed: () {
            if (widget.selected) {
              context
                  .read<SetupForm>()
                  .removeFromSelectedGenreList(widget.genre);

              setState(() {
                widget.selected = false;
              });
            } else {
              String? addedGenre = context
                  .read<SetupForm>()
                  .addToSelectedGenreList(widget.genre);

              if (addedGenre != null) {
                setState(() {
                  widget.selected = true;
                });
              }
            }
          },
          style: widget.selected
              ? Styles().selectedElevatedButtonStyle
              : Styles().unselectedElevatedButtonStyle,
          child: Text(widget.genre.replaceAll('-', ' '))),
    );
  }
}
