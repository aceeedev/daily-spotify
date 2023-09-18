import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/utils/filter_by_genre.dart';
import 'package:daily_spotify/utils/combine_top_items.dart';
import 'package:daily_spotify/utils/default_config.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/widgets/search_widget.dart';
import 'package:daily_spotify/styles.dart';

class GenreSelector extends StatefulWidget {
  const GenreSelector({super.key, required this.inSetup});
  final bool inSetup;

  @override
  State<GenreSelector> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {
  List<String> searchedTerms = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Pick your top three favorite genres',
            textAlign: TextAlign.center,
            style: Styles().subtitleText,
          ),
        ),
        FutureBuilder(
            future: getAndAddGenres(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('An error has occurred, ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<String> allPossibleGenres = snapshot.data!;
                  allPossibleGenres = allPossibleGenres
                      .map((e) => e.replaceAll('-', ' '))
                      .toList();

                  // check to see if something was selected and not in
                  //   recommended
                  List<String> selectedAndNotRec = [];
                  for (String selectedGenre
                      in context.read<SetupForm>().selectedGenreList) {
                    if (!(context
                        .read<SetupForm>()
                        .totalGenreList
                        .contains(selectedGenre))) {
                      print(selectedGenre);
                      selectedAndNotRec.add(selectedGenre);
                    }
                  }

                  return Expanded(
                    child: Column(
                      children: [
                        if (selectedAndNotRec.isNotEmpty) ...[
                          Text(
                            'Selected',
                            style: Styles().largeText,
                          ),
                          _simpleWrapChildren(
                            getGenreButtons(selectedAndNotRec),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Recommended',
                            style: Styles().largeText,
                          ),
                        ),
                        _simpleWrapChildren(
                          getGenreButtons(
                              context.watch<SetupForm>().totalGenreList),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Search(onSubmit: (searchedTerm) {
                            setState(() => searchedTerms = allPossibleGenres
                                .where(
                                    (element) => element.contains(searchedTerm))
                                .toList());
                          }),
                        ),
                        if (searchedTerms.isNotEmpty)
                          Expanded(
                            child: _simpleWrapChildren(
                                getGenreButtons(searchedTerms)),
                          ),
                        if (searchedTerms.isEmpty)
                          Expanded(
                              child: Text(
                            'No results',
                            style: Styles().subtitleText,
                          ))
                      ],
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

  /// Gets the user's top genres and saves them to Provider.
  /// Also returns all possible genres to select from.
  Future<List<String>> getAndAddGenres() async {
    AccessToken accessToken = await requestAccessTokenWithoutAuthCode(context);

    List<String> allPossibleGenres =
        await getAvailableGenreSeeds(accessToken: accessToken);

    List<Artist> artistList =
        (await combineTopItems(accessToken, Artist)).cast<Artist>().toList();

    // get artists from top global 50 songs on Spotify if needed
    if (artistList.isEmpty) {
      if (!mounted) return [];

      bool initiallyEmpty = context.read<SetupForm>().totalGenreList.isEmpty;
      if (initiallyEmpty) {
        context.read<SetupForm>().addAllToTotalGenreList(getDefaultGenres());
      }

      if (context.read<SetupForm>().totalArtistList.isEmpty && widget.inSetup) {
        context
            .read<SetupForm>()
            .addAllToTotalArtistList(await getDefaultArtists(accessToken));
      }

      return allPossibleGenres;
    }

    if (!mounted) return [];
    if (context.read<SetupForm>().totalArtistList.isEmpty && widget.inSetup) {
      context.read<SetupForm>().addAllToTotalArtistList(artistList);
    }

    Map<String, int> genresMap = await filterByGenre(accessToken, artistList);
    List<String> genresList = genresMap.keys.toList();
    if (genresList.isEmpty) {
      genresList = getDefaultGenres();
    }

    if (!mounted) return [];
    bool initiallyEmpty = context.read<SetupForm>().totalGenreList.isEmpty;

    List<String> savedGenres = await db.Config.instance.getGenreConfig();
    if (savedGenres.isNotEmpty) {
      if (!mounted) return [];

      for (String genre in savedGenres) {
        context.read<SetupForm>().addToSelectedGenreList(genre);

        genresList.remove(genre);
      }
    }

    if (!mounted) return [];
    if (initiallyEmpty) {
      context.read<SetupForm>().addAllToTotalGenreList(genresList);
    }

    if (!mounted) return [];
    context.read<SetupForm>().setFinishedStep(true);

    return allPossibleGenres;
  }

  List<Widget> getGenreButtons(List<String> genreList) {
    return genreList
        .map((e) => GenreButton(
            genre: e,
            selected: context.read<SetupForm>().selectedGenreList.contains(e)))
        .toList();
  }

  /// A method that returns a [SingleChildScrollView] of the provided children
  ///   wrapped.
  SingleChildScrollView _simpleWrapChildren(List<Widget> children) =>
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: children,
        ),
      );
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
