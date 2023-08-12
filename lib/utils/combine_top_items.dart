import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';
import 'package:daily_spotify/utils/evenly_distribute_lists.dart';

Future<List<dynamic>> combineTopItems(
    AccessToken accessToken, Type type) async {
  List<dynamic> shortTermList = await getUserTopItems(
      accessToken: accessToken, type: type, timeRange: 'short_term');
  List<dynamic> mediumTermList = await getUserTopItems(
      accessToken: accessToken, type: type, timeRange: 'medium_term');
  List<dynamic> longTermList = await getUserTopItems(
      accessToken: accessToken, type: type, timeRange: 'long_term');

  return evenlyDistributeLists(
      [mediumTermList, longTermList, shortTermList],
      (List<dynamic> combinedList, dynamic element) =>
          (combinedList.map((e) => e.id).contains(element.id))).toList();
}
