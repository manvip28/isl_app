import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:permission_handler/permission_handler.dart';

class LanguageToISLPage extends StatefulWidget {
  @override
  _LanguageToISLPageState createState() => _LanguageToISLPageState();
}

class _LanguageToISLPageState extends State<LanguageToISLPage> {
  final TextEditingController _textController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isLoading = false;
  bool _isListening = false;
  String _selectedSourceLanguage = 'en'; // Default source language

  // List of supported languages for translation
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},

    // Indian Languages
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'mr', 'name': 'Marathi'},
    {'code': 'gu', 'name': 'Gujarati'},
    {'code': 'pa', 'name': 'Punjabi'},
    {'code': 'bn', 'name': 'Bengali'},
    {'code': 'ta', 'name': 'Tamil'},
    {'code': 'te', 'name': 'Telugu'},
    {'code': 'kn', 'name': 'Kannada'},
    {'code': 'ml', 'name': 'Malayalam'},
    {'code': 'or', 'name': 'Odia'},

    // Other International Languages
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Request permissions on app start
  }

  // Request runtime permissions for camera and microphone
  void requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _convertToISL() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter some text', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, translate to English if not already in English
      String textToConvert = _textController.text;
      if (_selectedSourceLanguage != 'en') {
        var translation = await _translator.translate(
            textToConvert,
            from: _selectedSourceLanguage,
            to: 'en'
        );
        textToConvert = translation.text;
      }

      // Send to ISL conversion endpoint
      final response = await http.post(
        Uri.parse('http://192.168.1.7:5000/convert_to_isl'),
              // Replace <YOUR_COMPUTER_IP> with your machine's IP or <http://10.0.2.2:5000/convert_to_isl> in case of an emulator
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': textToConvert,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Navigate to result page with ISL text
        Navigator.pushNamed(
          context,
          '/result',
          arguments: responseData['isl_text'],
        );
      } else {
        _showSnackBar('Error converting text: ${response.body}', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Network error: $e', Colors.red);
    }
  }

  void _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (val) => print('Speech status: $val'),
      onError: (val) => print('Speech error: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (val) => setState(() {
          _textController.text = val.recognizedWords;
        }),
        localeId: _selectedSourceLanguage,
      );
    } else {
      _showSnackBar('Speech recognition not available', Colors.red);
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language to ISL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Convert Text to ISL',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Language Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Source Language',
                border: OutlineInputBorder(),
              ),
              value: _selectedSourceLanguage,
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSourceLanguage = value!;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text to translate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.text_fields),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: Icon(Icons.translate, size: 30),
              label: Text(
                'Translate to ISL',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: _convertToISL,
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
    );
  }
}
