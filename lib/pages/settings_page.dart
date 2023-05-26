import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/pages/donation_page.dart';
import 'package:daily_spotify/widgets/custom_scaffold.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/genre_selector.dart';
import 'package:daily_spotify/widgets/artist_selector.dart';
import 'package:daily_spotify/widgets/track_selector.dart';
import 'package:daily_spotify/widgets/developer_settings_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings',
            style: Styles().largeText,
          ),
          actions: [
            TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DonationPage())),
                label: const Text('Donate'),
                icon: const Icon(Icons.favorite_border))
          ],
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
                    List<SpotifyImage?> artistImageList = ((snapshot.data
                                as Map<String, dynamic>)['artistList']
                            as List<Artist>)
                        .map((e) => e.images != null ? e.images!.last : null)
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
                              settingsSelector: const GenreSelector(
                                inSetup: false,
                              ),
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
                            SettingsButton(
                              titleText: 'Disconnect',
                              descriptionText:
                                  'Remove this app from your Spotify account.',
                              buttonText: 'Manage Spotify Apps',
                              onPressed: () async {
                                Uri url = Uri.parse(
                                    'https://www.spotify.com/us/account/apps/');

                                if (!await launchUrl(url)) {
                                  throw Exception('Could not launch $url');
                                }
                              },
                            ),
                            kReleaseMode
                                ? const SizedBox.shrink()
                                : const DeveloperSettingsWidgets(),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' Created by andrew',
                                  style: Styles().subtitleText,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Icon(
                                    Icons.favorite,
                                    color: Styles().mainColor,
                                  ),
                                ),
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
                child: CircleAvatar(
                  radius: 21.0,
                  backgroundColor: Styles().secondaryColor,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Styles().primarySwatch,
                    ),
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingsEdit(
                                  settingsSelector: settingsSelector,
                                  onSave: onSave,
                                ))),
                    color: Styles().mainColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ]);
  }

  List<Widget> getCurrentSettingsWidgets() {
    List<Widget> currentSettings;

    if (items.isEmpty || items.contains(null)) {
      return [
        Text(
          'None selected. We will select for you',
          style: Styles().defaultText,
        )
      ];
    }

    switch (items.runtimeType) {
      case List<SpotifyImage>:
      case List<SpotifyImage?>:
        {
          currentSettings = items
              .map((e) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      e.url,
                      height: 64.0,
                      width: 64.0,
                      fit: BoxFit.cover,
                    ),
                  ))
              .toList();
        }
        break;
      case List<String>:
        {
          String itemsString = "";

          if (items.isNotEmpty) {
            // comma separated items
            itemsString = items.join(', ').replaceAll('-', ' ');

            // add ", and" to the last item if necessary
            if (items.length > 1) {
              int lastCommaIndex = itemsString.lastIndexOf(',');

              itemsString =
                  '${itemsString.substring(0, lastCommaIndex)}, and${itemsString.substring(lastCommaIndex + 1)}';
            }
          }

          currentSettings = [
            Text(
              itemsString,
              style: Styles().defaultText,
            )
          ];
        }
        break;
      default:
        {
          throw Exception(
              'items is not of type SpotifyImage, SpotifyImage?, or String, it is of type ${items.runtimeType}');
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
    return CustomScaffold(
        appBar: AppBar(
          centerTitle: true,
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
          showMetadataAttribute: true,
          child: Center(child: settingsSelector),
        ));
  }
}

/// A widget for displaying a text button for settings.
/// Requires [titleText], a [String] of the title of the setting,
/// [descriptionText], a [String] that is the description of the setting,
/// [buttonText] a [String] of the button's text , and [onPressed] a method that
/// is called when the text button has been pressed.
class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {super.key,
      required this.titleText,
      required this.descriptionText,
      required this.buttonText,
      required this.onPressed});
  final String titleText;
  final String descriptionText;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: Styles().largeText,
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                descriptionText,
                style: Styles().defaultText,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: onPressed,
                    style: Styles().unselectedElevatedButtonStyle,
                    child: Text(
                      buttonText,
                      style: Styles().subtitleTextWithPrimaryColor,
                    )),
              ),
            )
          ],
        ),
      ],
    );
  }
}
