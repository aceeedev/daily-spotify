import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/app.dart';
import 'package:daily_spotify/backend/spotify_api/models/access_token.dart';

void main() async {
  // Allows for async code in main method
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Register all custom objects in database
  Hive.registerAdapter(AccessTokenAdapter());

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SetupForm())],
      child: const MaterialApp(home: MyApp())));
}
