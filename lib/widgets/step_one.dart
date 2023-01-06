import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/providers/setup_provider.dart';

class StepOne extends StatefulWidget {
  const StepOne({super.key});

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
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
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], elevation: 0.0)
                : ElevatedButton.styleFrom(elevation: 1.5),
            child: const Text('Login with Spotify'),
          ),
        ),
      ],
    );
  }
}
