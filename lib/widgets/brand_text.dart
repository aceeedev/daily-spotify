import 'package:flutter/material.dart';
import 'package:daily_spotify/styles.dart';

class BrandText extends StatelessWidget {
  const BrandText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Your Pitch.',
      style: Styles().brandText,
    );
  }
}
