import 'package:hive/hive.dart';

part 'spotify_image.g.dart';

@HiveType(typeId: 3)
class SpotifyImage {
  @HiveField(0)
  int height;
  @HiveField(1)
  String url;
  @HiveField(2)
  int width;

  SpotifyImage({required this.height, required this.url, required this.width});
}
