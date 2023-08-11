import 'dart:math';

/// Returns a [List] created by indexing each of the elements in
/// [listsToCombine] sequentially.
///
/// If [detectRepeats] is passed, the output list will contain no duplicates.
/// [detectRepeats] should return a boolean value of true if a duplicate is
/// detected.
List evenlyDistributeLists(List<List> listsToCombine,
    Function(List<dynamic> combinedList, dynamic elementToAdd)? detectRepeats) {
  List<dynamic> combinedList = [];
  int largestLength = listsToCombine.map((e) => e.length).toList().reduce(max);

  for (int i = 0; i < largestLength; i++) {
    for (List<dynamic> list in listsToCombine) {
      if (i < list.length) {
        dynamic element = list[i];
        if (detectRepeats == null) {
          combinedList.add(element);
        } else if (!detectRepeats(combinedList, element)) {
          combinedList.add(element);
        }
      }
    }
  }

  return combinedList;
}
