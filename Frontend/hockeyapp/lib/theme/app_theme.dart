import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static final primaryColor = Colors.blue[900]; // Not const!
  static const accentColor = Color(0xFFFFD700);
  static const backgroundColor = Color(0xFFF4F4F4);
  static const cardColor = Colors.white;
  static const navBarBackgroundColor = Colors.white;
  static const navBarUnselectedColor = Colors.grey;

  // Text Styles (must be 'static final' if using non-const color)
  static final cardTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static final titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const subtitleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );
}
