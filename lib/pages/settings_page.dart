import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/genre_selector.dart';
import 'package:daily_spotify/widgets/artist_selector.dart';
import 'package:daily_spotify/widgets/track_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: Styles().largeText,
          ),
          backgroundColor: Styles().backgroundColor,
          leading: BackButton(color: Styles().mainColor),
        ),
        body: Frame(
            showLogo: false,
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('An error has occurred, ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<String> genreStringList = (snapshot.data
                        as Map<String, dynamic>)['genreList'] as List<String>;
                    List<SpotifyImage> artistImageList =
                        ((snapshot.data as Map<String, dynamic>)['artistList']
                                as List<Artist>)
                            .map((e) => e.images!.last)
                            .toList();
                    List<SpotifyImage> trackImageList =
                        ((snapshot.data as Map<String, dynamic>)['trackList']
                                as List<Track>)
                            .map((e) => e.images.last)
                            .toList();

                    return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SettingsListView(
                              text: 'Your favorite genres',
                              items: genreStringList,
                              settingsSelector: const GenreSelector(),
                              onSave: () async {
                                List<String> genreList =
                                    context.read<SetupForm>().selectedGenreList;

                                await db.Config.instance
                                    .saveGenreConfig(genreList);

                                setState(() {});
                              },
                            ),
                            SettingsListView(
                              text: 'Your favorite artists',
                              items: artistImageList,
                              settingsSelector: const ArtistSelector(),
                              onSave: () async {
                                List<Artist> artistList = context
                                    .read<SetupForm>()
                                    .selectedArtistList;

                                await db.Config.instance
                                    .saveArtistConfig(artistList);

                                setState(() {});
                              },
                            ),
                            SettingsListView(
                              text: 'Your favorite tracks',
                              items: trackImageList,
                              settingsSelector: const TrackSelector(),
                              onSave: () async {
                                List<Track> trackList =
                                    context.read<SetupForm>().selectedTrackList;

                                await db.Config.instance
                                    .saveTrackConfig(trackList);

                                setState(() {});
                              },
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Inspired by ella ',
                                  style: Styles().subtitleText,
                                ),
                                Icon(
                                  Icons.favorite,
                                  color: Styles().mainColor,
                                ),
                                Text(
                                  ' Created by andrew',
                                  style: Styles().subtitleText,
                                )
                              ],
                            )
                          ]),
                    );
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
              future: getSettings(),
            )));
  }

  /// Returns a [Future<Map<String, dynamic>>] which contains the current
  /// settings as the values, ['genreList'] as [List<String>], ['artistList'] as
  /// [List<Artist>], and ['trackList'] as [List<Track>].
  Future<Map<String, dynamic>> getSettings() async {
    List<String> genreList = await db.Config.instance.getGenreConfig();
    List<Artist> artistList = await db.Config.instance.getArtistConfig();
    List<Track> trackList = await db.Config.instance.getTrackConfig();

    return {
      'genreList': genreList,
      'artistList': artistList,
      'trackList': trackList,
    };
  }
}

/// A widget for displaying a row of items and an edit button.
/// Requires [text], a string that is displayed, [items] a [List] of either type
/// [SpotifyImage] or [String] depending if the items are an Artist / Track or
/// Genre, [settingsSelector], a widget of the interface to select new settings,
/// and [onSave] a method that is called when the edit has been saved.
class SettingsListView extends StatelessWidget {
  const SettingsListView(
      {super.key,
      required this.text,
      required this.items,
      required this.settingsSelector,
      required this.onSave});
  final String text;
  final List<dynamic> items;
  final Widget settingsSelector;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        text,
        style: Styles().largeText,
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            ...getCurrentSettingsWidgets(),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SettingsEdit(
                            settingsSelector: settingsSelector,
                            onSave: onSave,
                          ))),
                  color: Styles().mainColor,
                ),
              ),
            )
          ],
        ),
      ),
    ]);
  }

  dynamic getCurrentSettingsWidgets() {
    dynamic currentSettings;
    switch (items.runtimeType) {
      case List<SpotifyImage>:
        {
          currentSettings = items
              .map((e) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      e.url,
                      height: 64.0,
                      width: 64.0,
                    ),
                  ))
              .toList();
        }
        break;
      case List<String>:
        {
          currentSettings = [
            Text(
              items.join(', ').replaceAll('-', ' '),
              style: Styles().defaultText,
            )
          ];
        }
        break;
      default:
        {
          throw Exception(
              'items is not of type SpotifyImage or String, it is of type ${items.runtimeType}');
        }
    }

    return currentSettings;
  }
}

/// The edit page to change a setting.
/// Requires [settingsSelector], a widget of the interface to select new
/// settings and [onSave], a method that is called when the edit has been saved.
class SettingsEdit extends StatelessWidget {
  const SettingsEdit(
      {super.key, required this.settingsSelector, required this.onSave});
  final Widget settingsSelector;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Styles().backgroundColor,
          leading: BackButton(color: Styles().mainColor),
          actions: [
            IconButton(
                onPressed: () {
                  onSave();

                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.save,
                  color: Styles().mainColor,
                ))
          ],
        ),
        body: Frame(
          showLogo: false,
          child: Center(child: settingsSelector),
        ));
  }
}
