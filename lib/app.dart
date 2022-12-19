import 'package:flutter/material.dart';
import 'package:daily_spotify/pages/setup_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SetupPage(),
    );
  }
}
