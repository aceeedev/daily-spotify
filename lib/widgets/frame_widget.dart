import 'package:flutter/material.dart';

/// A widget that wraps the child in a SafeArea and a Padding widget.
///
/// Should be used as the body of a Scaffold on every page.
class Frame extends StatelessWidget {
  const Frame({super.key, required this.child});
  final Widget child;
  final double paddingSize = 10.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(padding: EdgeInsets.all(paddingSize), child: child));
  }
}
