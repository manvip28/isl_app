import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _videoController;
  bool _videoLoadError = false;
  List<String> _wordList = [];
  List<String> _videoUrls = [];
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Move from didChangeDependencies to initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load videos once to prevent multiple calls
    if (!_isDataLoaded) {
      _isDataLoaded = true;
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    final String? inputText = ModalRoute.of(context)?.settings.arguments as String?;

    print("Received inputText: $inputText"); // Debugging line

    if (inputText == null || inputText.isEmpty) {
      if (mounted) {
        setState(() => _videoLoadError = true);
      }
      return;
    }

    _wordList = inputText.toLowerCase().split(RegExp(r'\s+'));

    List<String> validVideoUrls = [];

    for (String word in _wordList) {
      String? videoUrl = _fetchVideoUrl(word);
      if (videoUrl != null) {
        validVideoUrls.add(videoUrl);
      }
    }

    if (validVideoUrls.isEmpty) {
      if (mounted) {
        setState(() => _videoLoadError = true);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _videoUrls = validVideoUrls;
      });
      _initializeVideo(0);
    }
  }

  String? _fetchVideoUrl(String word) {
    try {
      // Using getPublicUrl instead of createSignedUrl
      final String videoUrl = supabase.storage
          .from('videos')
          .getPublicUrl('$word.mp4');

      if (videoUrl.isNotEmpty) {
        print("Fetched URL for $word: $videoUrl");
        return videoUrl;
      } else {
        print("No valid URL for $word");
        return null;
      }
    } catch (e) {
      print("Error fetching video URL for $word: $e");
      return null;
    }
  }

  void _initializeVideo(int index) async {
    if (index >= _videoUrls.length) return;

    try {
      VideoPlayerController newController =
      VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));

      await newController.initialize();

      // Remove reference to previous controller before assigning new one
      final oldController = _videoController;

      if (mounted) {
        setState(() {
          _videoController = newController;
        });

        // Dispose of the old controller after state is updated
        if (oldController != null) {
          oldController.removeListener(() {});
          oldController.dispose();
        }

        newController.addListener(() {
          if (newController.value.position >= newController.value.duration) {
            _playNextVideo(index);
          }
        });

        _videoController!.play();
      } else {
        newController.dispose();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _videoLoadError = true);
      }
      print("Error loading video: $error");
    }
  }

  void _playNextVideo(int currentIndex) {
    if (currentIndex < _videoUrls.length - 1 && mounted) {
      _initializeVideo(currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Result Video',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple[800]),
              ),
              SizedBox(height: 30),
              if (_videoController != null && _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              else if (_videoLoadError)
                Text(
                  'Sorry, no videos found.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                )
              else
                CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Showing videos for: ${_wordList.join(' ')}',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Properly clean up before navigating
                  if (_videoController != null) {
                    _videoController!.pause();
                    _videoController!.removeListener(() {});
                  }
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple[600],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    if (_videoController != null) {
      _videoController!.removeListener(() {});
      _videoController!.dispose();
    }
    super.dispose();
  }
}
