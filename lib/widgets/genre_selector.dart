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
import 'package:daily_spotify/widgets/segmented_button_for_selectors_widget.dart';
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
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

                  return Expanded(
                    child: ListView(
                      children: [
                        if (context
                            .watch<SetupForm>()
                            .selectedGenreList
                            .isNotEmpty) ...[
                          Text(
                            'Selected',
                            style: Styles().largeText,
                            textAlign: TextAlign.center,
                          ),
                          _simpleWrapChildren(
                            getGenreButtons(
                                context.watch<SetupForm>().selectedGenreList),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: SegmentedButtonForSelectors(
                            recommendations:
                                context.watch<SetupForm>().totalGenreList,
                            type: String,
                            simpleWrapChildren: _simpleWrapChildren,
                            allPossibleGenres: allPossibleGenres,
                            getGenreButtons: getGenreButtons,
                          ),
                        ),
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
            ))
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
  const GenreButton({super.key, required this.genre});

  final String genre;

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
            if (context
                .read<SetupForm>()
                .selectedGenreList
                .contains(widget.genre)) {
              context
                  .read<SetupForm>()
                  .removeFromSelectedGenreList(widget.genre);
            } else {
              context.read<SetupForm>().addToSelectedGenreList(widget.genre);
            }
          },
          style: (context.watch<SetupForm>().selectedGenreList)
                  .contains(widget.genre)
              ? Styles().selectedElevatedButtonStyle
              : Styles().unselectedElevatedButtonStyle,
          child: Text(
            widget.genre.replaceAll('-', ' '),
            style: Styles().subtitleText,
          )),
    );
  }
}
