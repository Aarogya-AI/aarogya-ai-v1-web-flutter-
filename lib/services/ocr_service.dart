import 'dart:async';
import 'dart:convert';
import 'package:js/js.dart';

@JS('recognizeImageText')
external void recognizeImageText(String imageBase64, Function(String) callback);

class OcrService {
  static Future<String> extractTextFromImage(List<int> imageBytes) async {
    final completer = Completer<String>();
    final base64Image = 'data:image/png;base64,${base64Encode(imageBytes)}';

    try {
      recognizeImageText(
        base64Image,
        allowInterop((String responseText) {
          if (responseText.isNotEmpty) {
            completer.complete(responseText);
          } else {
            completer.completeError('No text detected in image');
          }
        }),
      );
    } catch (e) {
      completer.completeError('Failed to process image: $e');
    }

    return completer.future;
  }
}
