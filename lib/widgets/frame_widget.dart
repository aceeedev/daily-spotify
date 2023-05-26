import 'package:flutter/material.dart';
import 'package:daily_spotify/widgets/brand_text_widget.dart';
import 'package:daily_spotify/widgets/spotify_attribute_widget.dart';

/// A widget that wraps the child in a SafeArea and a Padding widget.
///
/// Should be used as the body of a Scaffold on every page.
class Frame extends StatelessWidget {
  const Frame(
      {super.key,
      required this.child,
      required this.showLogo,
      this.showMetadataAttribute = false,
      this.customPadding = const EdgeInsets.all(10.0)});
  final Widget child;
  final EdgeInsetsGeometry customPadding;
  final bool showLogo;
  final bool showMetadataAttribute;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: customPadding,
            child: Column(
              children: [
                showLogo ? const BrandText() : const SizedBox.shrink(),
                Expanded(child: child),
                showMetadataAttribute
                    ? const SpotifyAttribute()
                    : const SizedBox.shrink(),
              ],
            )));
  }
}
