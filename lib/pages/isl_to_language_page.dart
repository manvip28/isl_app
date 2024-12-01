import 'package:flutter/material.dart';

class ISLToLanguagePage extends StatefulWidget {
  @override
  _ISLToLanguagePageState createState() => _ISLToLanguagePageState();
}

class _ISLToLanguagePageState extends State<ISLToLanguagePage> {
  TextEditingController _textController = TextEditingController(); // To capture input text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ISL to Language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Enter Text'),
            ),
            SizedBox(height: 30),
            _buildActionButton(
              'Translate to ISL',
              Icons.translate,
                  () {
                // Get the entered text and pass it to the ResultPage
                String inputText = _textController.text;
                if (inputText.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/result',
                    arguments: inputText,  // Pass the input text to ResultPage
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30),
      label: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple[600],
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
    );
  }
}
