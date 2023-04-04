import 'package:daily_spotify/models/daily_track.dart';
import 'package:flutter/material.dart';
import 'package:daily_spotify/backend/database_manager.dart' as db;
import 'package:daily_spotify/styles.dart';
import 'package:daily_spotify/pages/setup_page.dart';
import 'package:daily_spotify/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Daily Spotify',
        theme: Styles().themeData,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('An error has occurred, ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  int length = (snapshot.data as List<DailyTrack>).length;

                  return length == 0 ? const SetupPage() : const HomePage();
                }
              }

              return const CircularProgressIndicator();
            }),
            future: db.Tracks.instance.getAllDailyTracks()));
  }
}
