import 'package:hive/hive.dart';
import './spotify_image.dart';

part 'artist.g.dart';

@HiveType(typeId: 2)
class Artist {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String uri;
  @HiveField(3)
  String spotifyUrl;
  @HiveField(4)
  List<SpotifyImage>? images;
  @HiveField(5)
  List<String>? genres;

  Artist(
      {required this.id,
      required this.name,
      required this.uri,
      required this.spotifyUrl,
      this.images,
      this.genres});
}
