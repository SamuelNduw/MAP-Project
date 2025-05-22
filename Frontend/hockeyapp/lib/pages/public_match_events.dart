// lib/pages/public_match_events.dart
import 'package:flutter/material.dart';

class PublicMatchEventsPage extends StatelessWidget {
  const PublicMatchEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> matchEvents = [
      {
        'category': 'Scoring',
        'type': 'Goal',
        'team': 'Team A',
        'scorer': 'Player 7',
        'assist': 'Player 10',
        'time': '15'
      },
      {
        'category': 'Penalties',
        'type': 'Card',
        'team': 'Team B',
        'player': 'Player 6',
        'cardType': 'Yellow',
        'reason': 'Rough play',
        'time': '25'
      },
      {
        'category': 'Game Flow',
        'type': 'Substitution',
        'team': 'Team A',
        'playerIn': 'Player 12',
        'playerOut': 'Player 3',
        'time': '30'
      },
      {
        'category': 'Other Events',
        'type': 'Video Review',
        'eventUnderReview': 'Goal',
        'outcome': 'Confirmed',
        'time': '40'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Events'),
      ),
      body: ListView.builder(
        itemCount: matchEvents.length,
        itemBuilder: (context, index) {
          final event = matchEvents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                '${event['category']} - ${event['type']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(event.entries
                  .where((e) => e.key != 'category' && e.key != 'type')
                  .map((e) => '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${e.value}')
                  .join('\n')),
            ),
          );
        },
      ),
    );
  }
}
