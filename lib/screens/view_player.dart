import 'package:flutter/material.dart';

class ViewPlayersScreen extends StatelessWidget {
  const ViewPlayersScreen({super.key});

  final List<Map<String, dynamic>> _players = const [
    {
      'name': 'Michael Adams',
      'team': 'Saints Hockey Club',
      'position': 'Forward',
      'image': 'assets/michael.jpg',
    },
    {
      'name': 'Jessica Lowe',
      'team': 'Wanderers Windhoek',
      'position': 'Goalkeeper',
      'image': 'assets/jessica.jpg',
    },
    {
      'name': 'Elago Haingura',
      'team': 'Windhoek Old Boys',
      'position': 'Defender',
      'image': 'assets/elago.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          leading: InkWell(
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Image.asset(
                'assets/logo.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        body:
            _players.isEmpty
                ? const Center(child: Text('No players to display yet.'))
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                player['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player['name'],
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    player['team'],
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    player['position'],
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
