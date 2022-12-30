import './spotify_image.dart';

class Artist {
  String id;
  String name;
  String uri;
  String spotifyUrl;
  List<SpotifyImage>? images;
  List<String>? genres;

  Artist(
      {required this.id,
      required this.name,
      required this.uri,
      required this.spotifyUrl,
      this.images,
      this.genres});
}
