import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String _selectedSourceLanguage = 'en';

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
    requestPermissions();
  }

  void requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _convertToISL() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter some text', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String textToConvert = _textController.text;
      if (_selectedSourceLanguage != 'en') {
        var translation = await _translator.translate(
            textToConvert,
            from: _selectedSourceLanguage,
            to: 'en'
        );
        textToConvert = translation.text;
      }

      final response = await http.post(
        Uri.parse('https://isl-backend-3zbp.onrender.com/convert_to_isl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': textToConvert}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Navigator.pushNamed(
          context,
          '/result',
          arguments: responseData['isl_text'],
        );
      } else {
        _showSnackBar('Error converting text: ${response.body}', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
    setState(() => _isListening = false);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to ISL', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Translate Text',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF311B92),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Convert written text or speech into Indian Sign Language videos.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),

            // Language Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.language, color: Color(0xFF673AB7)),
                    labelText: 'Source Language',
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  value: _selectedSourceLanguage,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF673AB7)),
                  items: _languages.map((lang) {
                    return DropdownMenuItem(
                      value: lang['code'],
                      child: Text(lang['name']!, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSourceLanguage = value!),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Text Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Type something to translate...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(24),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        color: _isListening ? Colors.redAccent : Color(0xFF673AB7),
                        size: 28,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),

            // Translate Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _convertToISL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Color(0xFF673AB7).withOpacity(0.4),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.translate_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Translate to ISL',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
