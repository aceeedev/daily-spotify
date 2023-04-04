import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

/// Returns [Future<Color>] of the average color from the imageUrl. Try to
/// pass a small image like 64x64.
Future<Color> getAverageColor(String imageUrl) async {
  http.Response response = await http.get(
    Uri.parse(imageUrl),
  );
  img.Image? bitmap = img.decodeImage(response.bodyBytes);

  int redBucket = 0;
  int greenBucket = 0;
  int blueBucket = 0;
  int pixelCount = 0;

  // try to pass a small image, ex: 64x64 = 4096 pixels
  for (int y = 0; y < bitmap!.height; y++) {
    for (int x = 0; x < bitmap.width; x++) {
      final pixel = bitmap.getPixel(x, y);

      pixelCount++;
      redBucket += pixel.r as int;
      greenBucket += pixel.g as int;
      blueBucket += pixel.b as int;
    }
  }

  return Color.fromRGBO(redBucket ~/ pixelCount, greenBucket ~/ pixelCount,
      blueBucket ~/ pixelCount, 1);
}
