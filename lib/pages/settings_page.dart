import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/backend/notification_manager.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/styles.dart';
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
          // TODO: Add donations through in-app purchases <3
          /*actions: [
            TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DonationPage())),
                label: const Text('Donate'),
                icon: const Icon(Icons.favorite_border))
          ],*/
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
                    Map<String, dynamic> data =
                        snapshot.data as Map<String, dynamic>;

                    List<Widget> children = _getChildren(data);

                    return Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: children.length,
                              itemBuilder: (context, index) => children[index],
                            ),
                          ),
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
                        ],
                      ),
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
  /// [List<Artist>], ['trackList'] as [List<Track>], and
  /// ['notificationsEnabled'] as [bool].
  Future<Map<String, dynamic>> getSettings() async {
    List<String> genreList = await db.Config.instance.getGenreConfig();
    List<Artist> artistList = await db.Config.instance.getArtistConfig();
    List<Track> trackList = await db.Config.instance.getTrackConfig();
    bool notificationsEnabled =
        await db.Config.instance.getNotificationsEnabled();

    return {
      'genreList': genreList,
      'artistList': artistList,
      'trackList': trackList,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  List<Widget> _getChildren(Map<String, dynamic> data) {
    List<String> genreStringList = data['genreList'] as List<String>;
    List<SpotifyImage?> artistImageList = (data['artistList'] as List<Artist>)
        .map((e) => e.images != null ? e.images!.last : null)
        .toList();
    List<SpotifyImage> trackImageList =
        (data['trackList'] as List<Track>).map((e) => e.images.last).toList();

    bool notificationsEnabled = data['notificationsEnabled'] as bool;

    return [
      SettingsListView(
        text: 'Your favorite genres',
        items: genreStringList,
        settingsSelector: const GenreSelector(
          inSetup: false,
        ),
        onSave: () async {
          List<String> genreList = context.read<SetupForm>().selectedGenreList;

          await db.Config.instance.saveGenreConfig(genreList);

          if (!mounted) return;
          context.read<SetupForm>().setSearchedGenreList([]);
          context.read<SetupForm>().resetSegmentedButtonValue();

          setState(() {});
        },
        onBackButtonPressed: () {
          context.read<SetupForm>().setSearchedGenreList([]);
          context.read<SetupForm>().resetSegmentedButtonValue();
        },
      ),
      SettingsListView(
        text: 'Your favorite artists',
        items: artistImageList,
        settingsSelector: const ArtistSelector(),
        onSave: () async {
          List<Artist> artistList =
              context.read<SetupForm>().selectedArtistList;

          await db.Config.instance.saveArtistConfig(artistList);

          if (!mounted) return;
          context.read<SetupForm>().setSearchedArtistList([]);
          context.read<SetupForm>().resetSegmentedButtonValue();

          setState(() {});
        },
        onBackButtonPressed: () {
          context.read<SetupForm>().setSearchedArtistList([]);
          context.read<SetupForm>().resetSegmentedButtonValue();
        },
      ),
      SettingsListView(
          text: 'Your favorite tracks',
          items: trackImageList,
          settingsSelector: const TrackSelector(),
          onSave: () async {
            List<Track> trackList = context.read<SetupForm>().selectedTrackList;

            await db.Config.instance.saveTrackConfig(trackList);

            if (!mounted) return;
            context.read<SetupForm>().setSearchedTrackList([]);
            context.read<SetupForm>().resetSegmentedButtonValue();

            setState(() {});
          },
          onBackButtonPressed: () {
            context.read<SetupForm>().setSearchedTrackList([]);
            context.read<SetupForm>().resetSegmentedButtonValue();
          }),
      SettingsButton(
        titleText: 'Disconnect',
        descriptionText: 'Remove this app from your Spotify account.',
        buttonText: 'Manage Spotify Apps',
        onPressed: () async {
          Uri url = Uri.parse('https://www.spotify.com/us/account/apps/');

          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
      ),
      SettingsSwitch(
        titleText: 'Enable notifications',
        descriptionText: 'Turn off and on push notifications for Your Pitch.',
        value: notificationsEnabled,
        onChanged: (bool value) async {
          await db.Config.instance.saveNotificationsEnabled(value);

          if (value) {
            NotificationManager.scheduleNotifications();
          } else {
            NotificationManager.cancelAllNotifications();
          }
        },
      ),
      kReleaseMode ? const SizedBox.shrink() : const DeveloperSettingsWidgets(),
    ];
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
      required this.onSave,
      this.onBackButtonPressed});
  final String text;
  final List<dynamic> items;
  final Widget settingsSelector;
  final VoidCallback onSave;
  final Function()? onBackButtonPressed;

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
                                  onBackButtonPressed: onBackButtonPressed,
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
                  '${itemsString.substring(0, lastCommaIndex)}${items.length > 2 ? ',' : ''} and${itemsString.substring(lastCommaIndex + 1)}';
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
      {super.key,
      required this.settingsSelector,
      required this.onSave,
      this.onBackButtonPressed});
  final Widget settingsSelector;
  final VoidCallback onSave;
  final Function()? onBackButtonPressed;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Styles().backgroundColor,
          leading: BackButton(
            color: Styles().mainColor,
            onPressed: () {
              if (onBackButtonPressed != null) {
                onBackButtonPressed!();
              }

              Navigator.of(context).pop();
            },
          ),
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

/// A widget for displaying a switch button for settings.
/// Requires [titleText], a [String] of the title of the setting,
/// [descriptionText], a [String] that is the description of the setting,
/// [value] a [bool] of the state of the switch, and
/// [onChanged] a method that takes in a boolean and is called when the switch
/// has been pressed.
class SettingsSwitch extends StatefulWidget {
  const SettingsSwitch(
      {super.key,
      required this.titleText,
      required this.descriptionText,
      required this.value,
      required this.onChanged});
  final String titleText;
  final String descriptionText;
  final bool value;
  final Function(bool) onChanged;

  @override
  State<SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  late bool valueOfSwitch;

  @override
  void initState() {
    valueOfSwitch = widget.value;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.titleText,
          style: Styles().largeText,
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                widget.descriptionText,
                style: Styles().defaultText,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: valueOfSwitch,
                  onChanged: (bool newValue) {
                    widget.onChanged(newValue);

                    setState(() => valueOfSwitch = newValue);
                  },
                  inactiveTrackColor: Styles().secondaryColor,
                  thumbColor:
                      MaterialStateProperty.all<Color>(Styles().primarySwatch),
                  inactiveThumbColor: Styles().primarySwatch,
                  trackOutlineColor:
                      MaterialStateProperty.all<Color>(Styles().secondaryColor),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
