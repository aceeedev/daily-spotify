import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/backend/spotify_api/auth.dart' as spotify_auth;
import 'package:daily_spotify/providers/setup_provider.dart';

class StepFour extends StatefulWidget {
  const StepFour({super.key});

  @override
  State<StepFour> createState() => _StepFourState();
}

class _StepFourState extends State<StepFour> {
  @override
  Widget build(BuildContext context) {
    return const Text("Step Four");
  }
}
