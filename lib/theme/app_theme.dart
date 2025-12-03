import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xff015AA5);
  static const secondaryColor = Color(0xFF0B74C9);
  static const background = Color(0xFFF6F8FC);

  static ThemeData lightTheme = ThemeData(
    fontFamily: "Poppins",
    primaryColor: primaryColor,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      color: Colors.white,
      foregroundColor: Colors.black,
    ),
  );
}
