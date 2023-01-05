import 'package:daily_spotify/backend/spotify_api/get_available_genre_seeds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/providers/setup_provider.dart';

class StepTwo extends StatefulWidget {
  const StepTwo({super.key});

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
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

    Map<String, int> genresMap = {};
    for (Artist artist in artistList) {
      artist.genres!.toList().forEach((genre) {
        if (genresMap[genre] == null) {
          genresMap[genre] = 1;
        } else {
          genresMap[genre] = genresMap[genre]! + 1;
        }
      });
    }

    // remove genres that are not able to be used as a recommendation
    List<String> availableSeedGenres =
        await getAvailableGenreSeeds(accessToken: accessToken);

    genresMap = genresMap
        .map((key, value) => MapEntry(key.replaceAll(' ', '-'), value));
    genresMap.removeWhere((key, value) => !availableSeedGenres.contains(key));

    // sort by descending value of number of times it appears in an artist
    genresMap = Map.fromEntries(genresMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value)));

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
    return TextButton(
        onPressed: () {
          if (widget.selected) {
            context.read<SetupForm>().removeFromSelectedGenreList(widget.genre);

            setState(() {
              widget.selected = false;
            });
          } else {
            String? addedGenre =
                context.read<SetupForm>().addToSelectedGenreList(widget.genre);

            if (addedGenre != null) {
              setState(() {
                widget.selected = true;
              });
            }
          }
        },
        style: widget.selected
            ? TextButton.styleFrom(backgroundColor: Colors.grey[200])
            : TextButton.styleFrom(),
        child: Text(widget.genre.replaceAll('-', ' ')));
  }
}
