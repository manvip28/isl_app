import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'detector_service_stub.dart'
    if (dart.library.io) 'detector_service_mobile.dart'
    if (dart.library.js_interop) 'detector_service_web.dart';

abstract class DetectorService {
  Future<bool> loadModel();
  Future<String?> processImage(CameraImage image);
  void dispose();

  static DetectorService create() => createDetector();
}
