import 'package:flutter/material.dart';

class LeaguesEventsScreen extends StatelessWidget {
  LeaguesEventsScreen({super.key});

  final List<Map<String, dynamic>> _content = [
    {
      'icon': Icons.sports_hockey,
      'title': 'Premier League',
      'description':
          'The top-tier hockey league featuring the best clubs from across Namibia.',
    },
    {
      'icon': Icons.school,
      'title': 'Schools League',
      'description':
          'Encouraging youth participation and competition among schools nationwide.',
    },
    {
      'icon': Icons.female, // ✅ FIXED: replaced invalid `Icons.women`
      'title': 'Women’s League',
      'description':
          'Empowering women in sports and growing the female hockey scene.',
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Independence Cup – March 21',
      'description':
          'An annual national hockey tournament celebrating Namibia’s independence.',
    },
    {
      'icon': Icons.sports,
      'title': 'Desert Series – June',
      'description':
          'A summer invitational for top clubs held in the Erongo region.',
    },
    {
      'icon': Icons.event_available,
      'title': 'FIH World Hockey Day',
      'description':
          'Global celebration of hockey with open matches, clinics and giveaways.',
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
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _content.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final item = _content[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item['icon'],
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'],
                            style: theme.textTheme.bodyMedium,
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
