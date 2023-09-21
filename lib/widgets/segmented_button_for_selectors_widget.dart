import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/widgets/search_widget.dart';
import 'package:daily_spotify/widgets/card_view_widget.dart';
import 'package:daily_spotify/utils/request_access_token_without_auth_code.dart';
import 'package:daily_spotify/styles.dart';

/// A custom segmented button meant for selectors. The parameter
/// [recommendations] is a [List] of type [type].
///
/// If [type] is String, also pass in the parameters, [simpleWrapChildren],
/// [allPossibleGenres], and [getGenreButtons].
class SegmentedButtonForSelectors extends StatefulWidget {
  const SegmentedButtonForSelectors(
      {super.key,
      required this.recommendations,
      required this.type,
      this.simpleWrapChildren,
      this.allPossibleGenres,
      this.getGenreButtons});
  final List<dynamic> recommendations;
  final Type type;
  // parameters for genres (type String)
  final Function(List<Widget>)? simpleWrapChildren;
  final List<String>? allPossibleGenres;
  final Function(List<String>)? getGenreButtons;

  @override
  State<SegmentedButtonForSelectors> createState() =>
      _SegmentedButtonForSelectorsState();
}

class _SegmentedButtonForSelectorsState
    extends State<SegmentedButtonForSelectors> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
                value: true,
                label: Text(
                  'Recommendations',
                  style: Styles().subtitleText,
                )),
            ButtonSegment<bool>(
                value: false,
                label: Text(
                  'Search',
                  style: Styles().subtitleText,
                ))
          ],
          selected: <bool>{context.watch<SetupForm>().segmentedButtonValue},
          onSelectionChanged: (_) =>
              context.read<SetupForm>().toggleSegmentedButtonValue(),
          showSelectedIcon: false,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Styles().selectedColor!;
                }
                return Styles().secondaryColor;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              if (context.watch<SetupForm>().segmentedButtonValue)
                recommendationWidgets(),
              if (!context.watch<SetupForm>().segmentedButtonValue)
                ...searchWidgets()
            ],
          ),
        ),
      ],
    );
  }

  Widget recommendationWidgets() {
    switch (widget.type) {
      case String:
        return widget.simpleWrapChildren!(
            widget.getGenreButtons!(widget.recommendations as List<String>));

      case Artist:
        return CardView(itemList: widget.recommendations, type: widget.type);

      case Track:
        return CardView(itemList: widget.recommendations, type: widget.type);

      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> searchWidgets() {
    switch (widget.type) {
      case String:
        return [
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Search(
                  onSubmit: (searchedTerm) => context
                      .read<SetupForm>()
                      .setSearchedGenreList(widget.allPossibleGenres!
                          .where((element) => element.contains(searchedTerm))
                          .toList()))),
          if (context.watch<SetupForm>().searchedGenreList.isNotEmpty)
            widget.simpleWrapChildren!(widget.getGenreButtons!(
                context.watch<SetupForm>().searchedGenreList)),
          if (context.watch<SetupForm>().searchedGenreList.isEmpty)
            Text(
              'No results',
              style: Styles().subtitleText,
              textAlign: TextAlign.center,
            )
        ];

      case Artist:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Search(onSubmit: (searchedTerm) async {
              AccessToken accessToken =
                  await requestAccessTokenWithoutAuthCode(context);

              List<Artist> searchResults = (await searchForItem(
                  accessToken: accessToken,
                  type: Artist,
                  term: searchedTerm)) as List<Artist>;

              if (!mounted) return;
              context.read<SetupForm>().setSearchedArtistList(searchResults);
            }),
          ),
          if (context.watch<SetupForm>().searchedArtistList.isNotEmpty)
            CardView(
                itemList: context.watch<SetupForm>().searchedArtistList,
                type: Artist),
          if (context.watch<SetupForm>().searchedArtistList.isEmpty)
            Text(
              'No results',
              style: Styles().subtitleText,
              textAlign: TextAlign.center,
            ),
        ];

      case Track:
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Search(onSubmit: (searchedTerm) async {
              AccessToken accessToken =
                  await requestAccessTokenWithoutAuthCode(context);

              List<Track> searchResults = (await searchForItem(
                  accessToken: accessToken,
                  type: Track,
                  term: searchedTerm)) as List<Track>;

              if (!mounted) return;
              context.read<SetupForm>().setSearchedTrackList(searchResults);
            }),
          ),
          if (context.watch<SetupForm>().searchedTrackList.isNotEmpty)
            CardView(
                itemList: context.watch<SetupForm>().searchedTrackList,
                type: Track),
          if (context.watch<SetupForm>().searchedTrackList.isEmpty)
            Text(
              'No results',
              style: Styles().subtitleText,
              textAlign: TextAlign.center,
            ),
        ];

      default:
        return [];
    }
  }
}
