import './track.dart';

class Recommendation {
  List<Seeds> seeds;
  List<Track> tracks;

  Recommendation({required this.seeds, required this.tracks});
}

class Seeds {
  int afterFilteringSize;
  int afterRelinkingSize;
  String? href;
  String id;
  int initialPoolSize;
  String type;

  Seeds(
      {required this.afterFilteringSize,
      required this.afterRelinkingSize,
      required this.href,
      required this.id,
      required this.initialPoolSize,
      required this.type});
}
