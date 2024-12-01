import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/isl_to_language_page.dart';
import 'pages/language_to_isl_page.dart';
import 'pages/result_page.dart';

void main() {
  runApp(ISLTranslatorApp());
}

class ISLTranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISL Translator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'lateRoboto',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple[600],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/isl-to-language': (context) => ISLToLanguagePage(),
        '/language-to-isl': (context) => LanguageToISLPage(),
        '/result': (context) => ResultPage(),
      },
    );
  }
}