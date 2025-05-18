import 'package:flutter/material.dart';
import 'package:hockey_union_app/screens/home_screen.dart';

void main() {
  runApp(HockeyUnionApp());
}

class HockeyUnionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namibia Hockey Union',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
