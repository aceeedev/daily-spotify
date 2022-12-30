import './artist.dart';
import './spotify_image.dart';

class Track {
  String id;
  String name;
  String uri;
  List<Artist> artists;
  List<SpotifyImage> images;

  Track(
      {required this.id,
      required this.name,
      required this.uri,
      required this.artists,
      required this.images});
}
