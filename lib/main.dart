import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/isl_to_language_page.dart';
import 'pages/language_to_isl_page.dart';
import 'pages/result_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before async operations

  await Supabase.initialize(
    url: 'https://lnftykdccfzbfsmodfnc.supabase.co',
    anonKey: 'sb_publishable_wCEMV-FJgb1M4d4EJdi-Iw_sVo6yeC_',
  );

  runApp(ISLTranslatorApp());
}

class ISLTranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISL Translator',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF673AB7), // Deep Purple
        scaffoldBackgroundColor: Color(0xFFF5F5F7), // Light Grey/White for premium feel
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF673AB7),
          secondary: Color(0xFF9575CD), // Lighter Purple
          background: Color(0xFFF5F5F7),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent, // Modern transparent app bar
          foregroundColor: Color(0xFF311B92), // Dark text for app bar
          iconTheme: IconThemeData(color: Color(0xFF311B92)),
          titleTextStyle: GoogleFonts.poppins(
            color: Color(0xFF311B92),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF673AB7),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
