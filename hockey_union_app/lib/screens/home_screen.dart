import 'package:flutter/material.dart';
import 'team_registration_screen.dart';
import 'event_entries_screen.dart';
import 'player_management_screen.dart';
import 'realtime_info_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Namibia Hockey Union')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TeamRegistrationScreen()),
              );
            },
            child: Text('Team Registration'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventEntriesScreen()),
              );
            },
            child: Text('Event Entries'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlayerManagementScreen()),
              );
            },
            child: Text('Player Management'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RealTimeInfoScreen()),
              );
            },
            child: Text('Real-Time Info'),
          ),
        ],
      ),
    );
  }
}
