import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/isl_to_language_page.dart';
import 'pages/language_to_isl_page.dart';
import 'pages/result_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/video_player_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before async operations

  await Supabase.initialize(
    url: <SUPABASE_PROJECT_URL> , // Replace with your Supabase project URL
    anonKey: <SUPABASE_ANON_KEY> , // Replace with your Supabase anon key
  );

  runApp(ISLTranslatorApp());
}

class ISLTranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Corrected syntax
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
        '/isl-to-language': (context) => IslToLanguagePage(),
        '/language-to-isl': (context) => LanguageToISLPage(),
        '/result': (context) => ResultPage(),
      },
    );
  }
}
