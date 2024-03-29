import 'package:flutter/material.dart';
import 'package:daily_spotify/styles.dart';

/// A custom loading indicator, similar to [CircularProgressIndicator].
///
/// The option parameter [text] is displayed below the loading icon.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: text != null
              ? Text(
                  text!,
                  style: Styles().defaultText,
                  textAlign: TextAlign.center,
                )
              : const SizedBox.shrink(),
        )
      ],
    ));
  }
}
