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
        const Text('Step Two'),
        const Text('Now pick your top three favorite genres.'),
        const Text(
            'If you don\'t know what genres to pick, just continue to the next step, you can always change these settings later.'),
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
        await getUserTopItems(accessToken: accessToken, type: 'artists');

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

          print(context.read<SetupForm>().selectedGenreList.toString());
        },
        style: widget.selected
            ? TextButton.styleFrom(backgroundColor: Colors.grey[200])
            : TextButton.styleFrom(),
        child: Text(widget.genre));
  }
}
