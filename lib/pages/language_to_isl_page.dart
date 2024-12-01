import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LanguageToISLPage extends StatefulWidget {
  @override
  _LanguageToISLPageState createState() => _LanguageToISLPageState();
}

class _LanguageToISLPageState extends State<LanguageToISLPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _convertToISL() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For Android emulator, use 'http://10.0.2.2:5000' to refer to your local machine
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/convert_to_isl'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': _textController.text,
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
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error converting text: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            SizedBox(height: 30),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text to translate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.text_fields),
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
