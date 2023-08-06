import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/widgets/custom_scaffold.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';
import 'package:daily_spotify/widgets/spotify_login.dart';

Future<AccessToken> requestAccessTokenWithoutAuthCode(
    BuildContext context) async {
  AccessToken? accessToken = await requestAccessToken(null);

  // request user auth if expired
  if (accessToken == null) {
    String? authCode = await requestUserAuth();

    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CustomScaffold(
                body: Frame(
              showLogo: true,
              child: SpotifyLogin(
                inSetup: false,
                authCode: authCode,
              ),
            ))));

    await getBrandNewAccessToken(authCode!);

    accessToken = await requestAccessToken(authCode);
  }

  return accessToken!;
}
