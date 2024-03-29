import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/providers/track_view_provider.dart';
import 'package:daily_spotify/providers/calendar_page_provider.dart';
import 'package:daily_spotify/app.dart';
import 'package:daily_spotify/backend/spotify_api/models/access_token.dart';
import 'package:daily_spotify/backend/spotify_api/models/artist.dart';
import 'package:daily_spotify/backend/spotify_api/models/spotify_image.dart';
import 'package:daily_spotify/backend/spotify_api/models/track.dart';
import 'package:daily_spotify/models/daily_track.dart';

void main() async {
  // Allows for async code in main method
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Register all custom objects in database, cant loop through
  // To register new TypeAdapters use:
  //   flutter packages pub run build_runner build
  Hive.registerAdapter(AccessTokenAdapter());
  Hive.registerAdapter(ArtistAdapter());
  Hive.registerAdapter(SpotifyImageAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(DailyTrackAdapter());

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SetupForm()),
        ChangeNotifierProvider(create: (_) => TrackViewProvider()),
        ChangeNotifierProvider(create: (_) => CalendarPageProvider())
      ],
      child: const MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      )));
}
