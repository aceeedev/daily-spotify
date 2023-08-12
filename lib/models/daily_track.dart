import 'package:hive/hive.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

part 'daily_track.g.dart';

@HiveType(typeId: 5)
class DailyTrack extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  Track track;
  @HiveField(2)
  String? reaction;
  @HiveField(3)
  int? _timesReshuffled;

  int get timesReshuffled => _timesReshuffled ?? 0;

  DailyTrack(
      {required this.date,
      required this.track,
      this.reaction,
      int? timesReshuffled}) {
    _timesReshuffled = timesReshuffled;
  }
}
