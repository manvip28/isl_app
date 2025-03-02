import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ISL Translator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Indian Sign Language Translator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            _buildTranslationButton(
              context,
              'ISL to Language',
              '/isl-to-language',
              Icons.sign_language,
            ),
            SizedBox(height: 20),
            _buildTranslationButton(
              context,
              'Language to ISL',
              '/language-to-isl',
              Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationButton(
      BuildContext context,
      String text,
      String route,
      IconData icon
      ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30),
      label: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
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
