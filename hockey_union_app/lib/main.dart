import 'package:flutter/material.dart';
import 'screens/team_registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_entries_screen.dart';
import 'screens/player_management_screen.dart';
import 'screens/realtime_info_screen.dart';

void main() {
  runApp(const HockeyUnionApp());
}

class HockeyUnionApp extends StatelessWidget {
  const HockeyUnionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hockey Union App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/team_registration': (context) => const TeamRegistrationScreen(),
        '/event_entries': (context) => const EventEntriesScreen(),
        '/player_management': (context) => const PlayerManagementScreen(),
        '/realtime_info': (context) => const RealtimeInfoScreen(),
      },
    );
  }
}
