import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/styles.dart';

class SpotifyLogin extends StatefulWidget {
  const SpotifyLogin({super.key});

  @override
  State<SpotifyLogin> createState() => _SpotifyLoginState();
}

class _SpotifyLoginState extends State<SpotifyLogin> {
  bool loggedIn = false;

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
                  await db.Auth.instance.saveAuthCode(authCode);

                  // get initial access token
                  await spotify_auth.requestAccessToken(authCode);

                  if (!mounted) return;
                  context.read<SetupForm>().setFinishedStep(true);
                  setState(() => loggedIn = true);
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
                    child: Image.asset('assets/Spotify_Icon_RGB_Green.png',
                        width: 32, height: 32),
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
}
