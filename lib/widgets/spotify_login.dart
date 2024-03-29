import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/pages/home_page.dart';

class SpotifyLogin extends StatefulWidget {
  const SpotifyLogin({super.key, required this.inSetup, this.authCode});
  final bool inSetup;
  final String? authCode;

  @override
  State<SpotifyLogin> createState() => _SpotifyLoginState();
}

class _SpotifyLoginState extends State<SpotifyLogin> {
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();

    if (widget.authCode != null) {
      refreshAuth(widget.authCode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Let\'s personalize your recommended music by checking out your Spotify',
          textAlign: TextAlign.center,
          style: Styles().subtitleText,
        ),
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                String? authCode = await spotify_auth.requestUserAuth();

                if (authCode != null) {
                  await spotify_auth.requestAccessToken(authCode);

                  if (widget.inSetup) {
                    await db.Auth.instance.saveAuthCode(authCode);

                    if (!mounted) return;
                    context.read<SetupForm>().setFinishedStep(true);
                    setState(() => loggedIn = true);
                  } else {
                    await refreshAuth(authCode);
                  }
                }
              },
              style: loggedIn
                  ? Styles().selectedElevatedButtonStyle
                  : Styles().unselectedElevatedButtonStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0, top: 8.0, bottom: 8.0),
                    child: Image.asset(
                        'assets/spotify/Spotify_Icon_RGB_Green.png',
                        width: 32,
                        height: 32),
                  ),
                  Text(
                    'Login with Spotify',
                    style: Styles().subtitleTextWithPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// gets a new access token and redirects back to the home page
  Future<void> refreshAuth(String authCode) async {
    await spotify_auth.getBrandNewAccessToken(authCode);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()));
  }
}
