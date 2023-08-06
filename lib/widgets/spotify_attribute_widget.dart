import 'package:flutter/material.dart';
import 'package:daily_spotify/styles.dart';

class SpotifyAttribute extends StatelessWidget {
  const SpotifyAttribute({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Any and all metadata and cover art data is provided by ',
          style: Styles().defaultText,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Spotify_Logo_RGB_Green.png',
              height: 24.0,
            ),
            Text(
              ' and their respective services.',
              style: Styles().defaultText,
            ),
          ],
        )
      ],
    );
  }
}
