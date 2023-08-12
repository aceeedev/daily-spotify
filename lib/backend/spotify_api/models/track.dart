import 'package:hive/hive.dart';
import './artist.dart';
import './spotify_image.dart';

part 'track.g.dart';

@HiveType(typeId: 4)
class Track extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String uri;
  @HiveField(3)
  String spotifyHref;
  @HiveField(4)
  List<Artist> artists;
  @HiveField(5)
  List<SpotifyImage> images;

  Track(
      {required this.id,
      required this.name,
      required this.uri,
      required this.spotifyHref,
      required this.artists,
      required this.images});

  String getArtists() {
    List<String> artists = [];
    for (Artist artist in this.artists) {
      artists.add(artist.name);
    }

    return artists.join(', ');
  }
}
