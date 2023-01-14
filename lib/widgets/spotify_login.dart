import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
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
          'Let\'s personalize your music by checking out your Spotify',
          textAlign: TextAlign.center,
          style: Styles().subtitleText,
        ),
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                String? authCode = await spotify_auth.requestUserAuth();

                if (authCode != null) {
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
              child: const Text('Login with Spotify'),
            ),
          ),
        ),
      ],
    );
  }
}
