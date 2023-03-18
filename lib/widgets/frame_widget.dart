import 'package:flutter/material.dart';
import 'package:daily_spotify/widgets/brand_text.dart';
import 'package:daily_spotify/styles.dart';

/// A widget that wraps the child in a SafeArea and a Padding widget.
///
/// Should be used as the body of a Scaffold on every page.
class Frame extends StatelessWidget {
  const Frame(
      {super.key,
      required this.child,
      required this.showLogo,
      this.showMetadataAttribute = false});
  final Widget child;
  final double paddingSize = 10.0;
  final bool showLogo;
  final bool showMetadataAttribute;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.all(paddingSize),
            child: Column(
              children: [
                showLogo ? const BrandText() : const SizedBox.shrink(),
                Expanded(child: child),
                showMetadataAttribute
                    ? Column(
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
                      )
                    : const SizedBox.shrink(),
              ],
            )));
  }
}
