import 'package:flutter/material.dart';
import 'package:daily_spotify/widgets/brand_text.dart';

/// A widget that wraps the child in a SafeArea and a Padding widget.
///
/// Should be used as the body of a Scaffold on every page.
class Frame extends StatelessWidget {
  const Frame({super.key, required this.child, required this.showLogo});
  final Widget child;
  final double paddingSize = 10.0;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.all(paddingSize),
            child: Column(
              children: [
                showLogo ? const BrandText() : const SizedBox.shrink(),
                Expanded(child: child),
              ],
            )));
  }
}
