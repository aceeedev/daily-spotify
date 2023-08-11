import 'package:daily_spotify/utils/default_config.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/utils/filter_by_genre.dart';
import 'package:daily_spotify/utils/evenly_distribute_lists.dart';
import 'package:daily_spotify/styles.dart';

class GenreSelector extends StatefulWidget {
  const GenreSelector({super.key, required this.inSetup});
  final bool inSetup;

  @override
  State<GenreSelector> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pick your top three favorite genres',
          textAlign: TextAlign.center,
          style: Styles().subtitleText,
        ),
        FutureBuilder(
            future: getAndAddGenres(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('An error has occurred, ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: getGenreButtons(
                              context.read<SetupForm>().totalGenreList),
                        ),
                      ),
                    ),
                  );
                }
              }

              return const Expanded(
                  child: LoadingIndicator(text: 'Finding your top genres...'));
            }),
      ],
    );
  }

  Future<bool> getAndAddGenres() async {
    AccessToken accessToken = await requestAccessTokenWithoutAuthCode(context);

    List<Artist> shortTermList = await getUserTopItems(
        accessToken: accessToken, type: Artist, timeRange: 'short_term');
    List<Artist> mediumTermList = await getUserTopItems(
        accessToken: accessToken, type: Artist, timeRange: 'medium_term');
    List<Artist> longTermList = await getUserTopItems(
        accessToken: accessToken, type: Artist, timeRange: 'long_term');

    List<Artist> artistList = evenlyDistributeLists(
        [mediumTermList, longTermList, shortTermList],
        (List<dynamic> combinedList, dynamic element) => (combinedList
            .map((e) => (e as Artist).id)
            .contains(element.id))).cast<Artist>().toList();

    // get artists from top global 50 songs on Spotify if needed
    if (artistList.isEmpty) {
      if (!mounted) return false;

      bool initiallyEmpty = context.read<SetupForm>().totalGenreList.isEmpty;
      if (initiallyEmpty) {
        context.read<SetupForm>().addAllToTotalGenreList(getDefaultGenres());
      }

      if (context.read<SetupForm>().totalArtistList.isEmpty && widget.inSetup) {
        context
            .read<SetupForm>()
            .addAllToTotalArtistList(await getDefaultArtists(accessToken));
      }

      return true;
    }

    if (!mounted) return false;
    if (context.read<SetupForm>().totalArtistList.isEmpty && widget.inSetup) {
      context.read<SetupForm>().addAllToTotalArtistList(artistList);
    }

    Map<String, int> genresMap = await filterByGenre(accessToken, artistList);
    List<String> genresList = genresMap.keys.toList();
    if (!mounted) return false;
    bool initiallyEmpty = context.read<SetupForm>().totalGenreList.isEmpty;

    List<String> savedGenres = await db.Config.instance.getGenreConfig();
    if (savedGenres.isNotEmpty) {
      if (!mounted) return false;

      for (String genre in savedGenres) {
        context.read<SetupForm>().addToSelectedGenreList(genre);

        genresList.remove(genre);
      }

      if (initiallyEmpty) {
        context.read<SetupForm>().addAllToTotalGenreList(savedGenres);
      }
    }

    if (!mounted) return false;
    if (initiallyEmpty) {
      context.read<SetupForm>().addAllToTotalGenreList(genresList);
    }
    context.read<SetupForm>().setFinishedStep(true);

    return true;
  }

  List<Widget> getGenreButtons(List<String> genreList) {
    return genreList
        .map((e) => GenreButton(
            genre: e,
            selected: context.read<SetupForm>().selectedGenreList.contains(e)))
        .toList();
  }
}

// ignore: must_be_immutable
class GenreButton extends StatefulWidget {
  GenreButton({super.key, required this.genre, required this.selected});

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
          child: Text(
            widget.genre.replaceAll('-', ' '),
            style: Styles().subtitleText,
          )),
    );
  }
}
