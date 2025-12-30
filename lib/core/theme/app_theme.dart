import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0092D1),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0092D1),
      primary: const Color(0xFF0092D1),
      secondary: const Color(0xFF66C14F),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
  );
}
