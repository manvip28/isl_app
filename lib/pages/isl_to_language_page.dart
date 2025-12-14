import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:google_fonts/google_fonts.dart';

class IslToLanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignLanguageDetector();
  }
}

class SignLanguageDetector extends StatefulWidget {
  @override
  _SignLanguageDetectorState createState() => _SignLanguageDetectorState();
}

class _SignLanguageDetectorState extends State<SignLanguageDetector> with WidgetsBindingObserver {
  CameraController? _cameraController;
  Interpreter? _interpreter;
  String _detectedCharacter = 'Waiting...';
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  bool _isPaused = false; // Paused state for 30-second delay

  DateTime? _lastProcessedTime;
  static const Duration _processingInterval = Duration(milliseconds: 500);
  static const Duration _pauseDuration = Duration(seconds: 30);

  final List<String> _characters = List.generate(26, (index) => String.fromCharCode(65 + index));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeAll() async {
    await _loadModel();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras found');
        return;
      }

      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Increased resolution for better display
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startImageStream();
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      ByteData data = await rootBundle.load('assets/sign_language_model.tflite');

      if (data.buffer.lengthInBytes == 0) {
        print('Model file is empty!');
        return;
      }

      _interpreter = await Interpreter.fromBuffer(data.buffer.asUint8List());
      print('Model loaded successfully');
    } catch (e) {
      print('Detailed model loading error: $e');
    }
  }

  void _startImageStream() {
    if (_cameraController == null) return;

    try {
      _cameraController!.startImageStream((CameraImage image) {
        if (_isPaused) return;

        final now = DateTime.now();
        if (_lastProcessedTime == null ||
            now.difference(_lastProcessedTime!) >= _processingInterval) {
          if (!_isProcessing && _interpreter != null) {
            _processImage(image);
            _lastProcessedTime = now;
          }
        }
      });
    } catch (e) {
      print('Image stream error: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      var preprocessedImage = _fastPreprocessImage(image);
      if (preprocessedImage == null) {
        print('Preprocessing failed');
        return;
      }

      var output = List.filled(1 * 25, 0.0).reshape([1, 25]);
      _interpreter!.run(preprocessedImage, output);

      int predClass = _findMaxIndexWithConfidence(output[0]);

      if (predClass != -1) {
        String detectedChar = _characters[predClass];

        if (mounted) {
          setState(() {
            _detectedCharacter = detectedChar;
            _isPaused = true;
          });

          // Resume recognition after 30 seconds
          Future.delayed(_pauseDuration, () {
            if (mounted) {
              setState(() {
                _isPaused = false;
                _detectedCharacter = 'Waiting...';
              });
            }
          });
        }
      }
    } catch (e) {
      print('Image processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive feel
      appBar: AppBar(
        title: Text('Sign Language Detector', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator(color: Colors.white)),

          // Overlay
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detected Character',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _detectedCharacter,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isPaused)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Paused for 30s',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
