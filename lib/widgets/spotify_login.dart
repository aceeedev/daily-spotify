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
        const Text(
          'First we need to personalize your music taste by viewing your Spotify account',
          textAlign: TextAlign.center,
        ),
        Center(
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
      ],
    );
  }
}
