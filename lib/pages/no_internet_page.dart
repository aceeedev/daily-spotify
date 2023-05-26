import 'package:flutter/material.dart';
import 'package:daily_spotify/widgets/loading_indicator_widget.dart';
import 'package:daily_spotify/widgets/frame_widget.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Frame(
        showLogo: true,
        child: Center(
          child: LoadingIndicator(
              text:
                  'Could not connect to the internet, please check your internet connection <3'),
        ),
      ),
    );
  }
}
