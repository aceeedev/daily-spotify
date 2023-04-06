import 'package:flutter/material.dart';
import 'package:daily_spotify/styles.dart';

class SpotifyAttribute extends StatelessWidget {
  const SpotifyAttribute({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Any and all metadata and cover art data is provided by Spotify and their respective services.',
            textAlign: TextAlign.center,
            style: Styles().defaultText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/Spotify_Logo_RGB_Green.png',
            height: 24.0,
          ),
        )
      ],
    );
  }
}
