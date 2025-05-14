import 'package:flutter/material.dart';

class GetInvolvedScreen extends StatelessWidget {
  const GetInvolvedScreen({super.key});

  final List<Map<String, dynamic>> _sections = const [
    {
      'title': 'Volunteer',
      'icon': Icons.volunteer_activism,
      'content':
          'Join our team as a volunteer and support local hockey events, youth programs, or administrative tasks. Your time makes a difference.',
    },
    {
      'title': 'Coaching & Umpiring',
      'icon': Icons.sports,
      'content':
          'Become a certified coach or umpire. We provide training, resources, and certification paths to support your hockey career.',
    },
    {
      'title': 'Partner or Sponsor',
      'icon': Icons.handshake,
      'content':
          'We welcome corporate partners who want to support Namibian hockey through sponsorships and collaborations.',
    },
    {
      'title': 'Donate',
      'icon': Icons.card_giftcard,
      'content':
          'Every contribution helps us fund development, equipment, and outreach programs. Help us grow hockey across Namibia.',
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
          itemCount: _sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final section = _sections[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      section['icon'],
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            section['content'],
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
