import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Donations',
            style: Styles().largeText,
          ),
          backgroundColor: Styles().backgroundColor,
          leading: BackButton(color: Styles().mainColor),
        ),
        body: Frame(
            showLogo: false,
            child: Column(
              children: [
                Text(
                  'Hello, my name is Andrew and I am a student studying computer science and engineering. As much as I love developing apps, they take a lot of time and effort to create. I would greatly appreciate any donations. All donations would go towards helping me develop more amazing apps <3',
                  style: Styles().subtitleText,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Note: The ${Platform.isAndroid ? "Play Store" : Platform.isIOS ? "App Store" : "store"} takes a ~30% cut out of all in-app and app purchases.',
                    style: Styles().subtitleText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )));
  }
}
