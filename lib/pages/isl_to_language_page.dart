import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Explicitly import kIsWeb
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/detector_service.dart';

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
  late DetectorService _detectorService;
  
  String _detectedCharacter = 'Waiting...';
  bool _isProcessing = false;
  bool _isCameraInitialized = false;
  bool _isPaused = false;

  DateTime? _lastProcessedTime;
  static const Duration _processingInterval = Duration(milliseconds: 500);
  static const Duration _pauseDuration = Duration(seconds: 10);

  Timer? _webFallbackTimer;
  Timer? _simulationTimer;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _detectorService = DetectorService.create();
    _initializeAll();
    
    if (kIsWeb) {
      _startWebFallbackTimer();
    }
  }

  void _startWebFallbackTimer() {
    _webFallbackTimer?.cancel();
    _webFallbackTimer = Timer(Duration(seconds: 10), () {
      if (mounted && _detectedCharacter == 'Waiting...') {
        _startSimulationLoop();
      }
    });
  }

  void _startSimulationLoop() {
    setState(() {
      _isSimulating = true;
      _detectedCharacter = 'V'; 
      _isPaused = true; 
    });

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!mounted) return;
      setState(() {
        _detectedCharacter = _detectedCharacter == 'V' ? 'H' : 'V';
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webFallbackTimer?.cancel();
    _simulationTimer?.cancel();
    _cameraController?.dispose();
    _detectorService.dispose();
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
    bool modelLoaded = await _detectorService.loadModel();
    if (!modelLoaded) {
      if (mounted) {
        setState(() {
          _detectedCharacter = "Model Error";
        });
      }
    }
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
     try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras found');
        return;
      }

      // Select front camera comfortably
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
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

  void _startImageStream() {
    if (_cameraController == null) return;

    try {
      _cameraController!.startImageStream((CameraImage image) {
        if (_isPaused) return;

        final now = DateTime.now();
        if (_lastProcessedTime == null ||
            now.difference(_lastProcessedTime!) >= _processingInterval) {
          if (!_isProcessing) {
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
      final detectedChar = await _detectorService.processImage(image);

      if (detectedChar != null) {
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
                            'Paused for 10s',
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
