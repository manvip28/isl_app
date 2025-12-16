import 'dart:js_interop';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'detector_service.dart';

@JS('window.loadTFLiteModel')
external JSPromise<JSBoolean> loadTFLiteModelJS(JSString path);

@JS('window.runInference')
external JSPromise<JSString?> runInferenceJS(JSAny imageData);

class DetectorServiceWeb implements DetectorService {
  @override
  Future<bool> loadModel() async {
    // For web, we might need a relative path or a hosted URL.
    // Flutter web assets vary in path depending on base href.
    // We try multiple common paths.
    
    final paths = [
      'assets/assets/sign_language_model.tflite',
      'assets/sign_language_model.tflite',
      'sign_language_model.tflite',
    ];

    bool loaded = false;
    for (final path in paths) {
      if (loaded) break;
      try {
        print("Attempting to load model from: $path");
        final result = await loadTFLiteModelJS(path.toJS).toDart;
        if (result.toDart) {
          loaded = true;
          print("Successfully loaded model from: $path");
        }
      } catch (e) {
        print("Failed to load from $path: $e");
      }
    }
    
    if (!loaded) {
      print("CRITICAL: Failed to load TFLite model from all attempted paths.");
    }
    return loaded;
  }

  @override
  Future<String?> processImage(CameraImage image) async {
    if (image.planes.isEmpty) return null;

    try {
      // On Web, CameraImage usually comes as RGBA (4 bytes per pixel)
      // We need to verify this assumption or wrap in try-catch.
      final bytes = image.planes[0].bytes;
      final int width = image.width;
      final int height = image.height;
      final int stride = 4; // Assuming RGBA

      // Target size 64x64
      final Float32List inputData = Float32List(64 * 64 * 3);

      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          // Nearest Neighbor scaling
          int srcX = (x * width) ~/ 64;
          int srcY = (y * height) ~/ 64;

          int index = (srcY * width + srcX) * stride;
          
          // Safety check
          if (index + 2 >= bytes.length) continue;

          // Normalize to 0.0 - 1.0
          inputData[(y * 64 + x) * 3 + 0] = bytes[index] / 255.0;     // R
          inputData[(y * 64 + x) * 3 + 1] = bytes[index + 1] / 255.0; // G
          inputData[(y * 64 + x) * 3 + 2] = bytes[index + 2] / 255.0; // B
        }
      }

      // Send to JS
      final result = await runInferenceJS(inputData.toJS).toDart;
      return result?.toDart;
      
    } catch (e) {
      print("Web processing error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    // No explicit dispose needed for global JS model yet
  }
}

DetectorService createDetector() => DetectorServiceWeb();
