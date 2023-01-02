import 'package:hive/hive.dart';
import './artist.dart';
import './spotify_image.dart';

part 'track.g.dart';

@HiveType(typeId: 4)
class Track {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String uri;
  @HiveField(3)
  List<Artist> artists;
  @HiveField(4)
  List<SpotifyImage> images;

  Track(
      {required this.id,
      required this.name,
      required this.uri,
      required this.artists,
      required this.images});
}
