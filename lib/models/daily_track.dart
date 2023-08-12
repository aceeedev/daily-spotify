import 'package:hive/hive.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

part 'daily_track.g.dart';

@HiveType(typeId: 5)
class DailyTrack {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  Track track;
  @HiveField(2)
  String? reaction;
  @HiveField(3)
  int timesReshuffled;

  DailyTrack(
      {required this.date,
      required this.track,
      this.reaction,
      this.timesReshuffled = 0});
}
