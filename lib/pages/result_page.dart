import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _videoController;
  bool _videoLoadError = false;
  List<String> _wordList = [];

  // Map the input words to corresponding videos
  Map<String, String> videoMap = {
    'abacus': 'assets/videos/Abacus.mp4',
    'abstract': 'assets/videos/Abstract.mp4',
    'chocolate':'assets/videos/Chocolate.mp4',
    'like':'assets/videos/Like.mp4'

    // Add more words and video paths here
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCombinedVideo();
  }

  // Load and combine videos for multiple words
  void _loadCombinedVideo() async {
    // Get the input text from route arguments
    final String inputText = ModalRoute.of(context)!.settings.arguments as String;

    // Split the input text into words
    _wordList = inputText.toLowerCase().split(RegExp(r'\s+'));

    // Find video paths for the words
    List<String> validVideoPaths = [];
    for (String word in _wordList) {
      if (videoMap.containsKey(word)) {
        validVideoPaths.add(videoMap[word]!);
      }
    }

    // Check if any videos were found
    if (validVideoPaths.isEmpty) {
      setState(() {
        _videoLoadError = true;
      });
      return;
    }

    try {
      // Initialize video controller with the first video
      _videoController = VideoPlayerController.asset(validVideoPaths[0]);
      await _videoController!.initialize();

      // Set up a listener to play the next video when one finishes
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          _playNextVideo(validVideoPaths);
        }
      });

      // Start playing
      setState(() {});
      _videoController!.play();
    } catch (error) {
      setState(() {
        _videoLoadError = true;
      });
      print("Error loading video: $error");
    }
  }

  // Method to play the next video in the sequence
  void _playNextVideo(List<String> videoPaths) async {
    // Dispose of the current video controller
    await _videoController?.dispose();

    // Find the index of the current video
    int currentIndex = videoPaths.indexOf(_videoController!.dataSource);

    // If there's a next video, play it
    if (currentIndex < videoPaths.length - 1) {
      _videoController = VideoPlayerController.asset(videoPaths[currentIndex + 1]);
      await _videoController!.initialize();

      // Set up listener for the next video
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          _playNextVideo(videoPaths);
        }
      });

      setState(() {});
      _videoController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Result Video',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              SizedBox(height: 30),
              // Video player section
              if (_videoController != null && _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              if (_videoController == null || !_videoController!.value.isInitialized)
                if (_videoLoadError)
                  Text(
                    'Sorry, no videos could be found for the entered words.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  )
                else
                  CircularProgressIndicator(),
              SizedBox(height: 20),
              // Display the words being shown
              Text(
                'Showing videos for: ${_wordList.join(', ')}',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _videoController?.dispose();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple[600],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}