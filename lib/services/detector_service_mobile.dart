import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'detector_service.dart';

class DetectorServiceMobile implements DetectorService {
  Interpreter? _interpreter;
  final List<String> _characters = List.generate(26, (index) => String.fromCharCode(65 + index));

  @override
  Future<void> loadModel() async {
    try {
      // Note: On mobile we load from assets, on web we might load from URL.
      // tflite_flutter loads directly from asset bundle.
      _interpreter = await Interpreter.fromAsset('assets/sign_language_model.tflite');
      print('Mobile Model loaded successfully');
    } catch (e) {
      print('Error loading mobile model: $e');
    }
  }

  @override
  Future<String?> processImage(CameraImage image) async {
    if (_interpreter == null) return null;

    try {
      var preprocessedImage = _fastPreprocessImage(image);
      if (preprocessedImage == null) return null;

      var output = List.filled(1 * 25, 0.0).reshape([1, 25]);
      _interpreter!.run(preprocessedImage, output);

      int predClass = _findMaxIndexWithConfidence(output[0]);
      if (predClass != -1) {
        return _characters[predClass];
      }
    } catch (e) {
      print('Mobile processing error: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _interpreter?.close();
  }

  // Helper methods from the original page
  int _findMaxIndexWithConfidence(List<double> list, {double threshold = 0.5}) {
    double maxValue = list.reduce((curr, next) => curr > next ? curr : next);
    if (maxValue >= threshold) {
      return list.indexOf(maxValue);
    }
    return -1;
  }

  dynamic _fastPreprocessImage(CameraImage image) {
     try {
      if (image.planes.length != 3) return null;

      Float32List imageData = Float32List(64 * 64 * 3);
      final int width = 64;
      final int height = 64;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final sourceX = x * image.width ~/ width;
          final sourceY = y * image.height ~/ height;

          final yIndex = sourceY * image.planes[0].bytesPerRow + sourceX;
          final uvIndex = (sourceY ~/ 2) * image.planes[1].bytesPerRow + (sourceX ~/ 2);

          if (yIndex >= image.planes[0].bytes.length ||
              uvIndex >= image.planes[1].bytes.length ||
              uvIndex >= image.planes[2].bytes.length) {
            continue;
          }

          final yValue = image.planes[0].bytes[yIndex];
          final uValue = image.planes[1].bytes[uvIndex];
          final vValue = image.planes[2].bytes[uvIndex];

          final r = ((yValue + 1.402 * (vValue - 128)) / 255).clamp(0.0, 1.0);
          final g = ((yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128)) / 255).clamp(0.0, 1.0);
          final b = ((yValue + 1.772 * (uValue - 128)) / 255).clamp(0.0, 1.0);

          imageData[y * width * 3 + x * 3] = r.toDouble();
          imageData[y * width * 3 + x * 3 + 1] = g.toDouble();
          imageData[y * width * 3 + x * 3 + 2] = b.toDouble();
        }
      }

      return imageData.reshape([1, 64, 64, 3]);
    } catch (e) {
      print('Fast preprocessing error: $e');
      return null;
    }
  }

}

DetectorService createDetector() => DetectorServiceMobile();
