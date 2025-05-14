import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> _sections = const [
    {
      'title': 'About Namibia Hockey Union',
      'content':
          'The Namibia Hockey Union (NHU) is the governing body of field hockey in Namibia. '
          'It is affiliated to the International Hockey Federation (FIH) and the African Hockey Federation (AfHF). '
          'The headquarters are located in Windhoek, Namibia.',
    },
    {
      'title': 'Executive Committee',
      'content':
          'President: Reagon Graig\n'
          'Vice-President (Women): Marietta Stoffberg\n'
          'Vice-President (Men): Conrad Wessels\n'
          'Secretary-General: Jens Unterlechner\n'
          'Treasurer: Julia Lasarus\n'
          'Additional Members:\n'
          ' - Ingrid Hermanus (Tours & Tournaments)\n'
          ' - Sedtric Makati (Umpires, Fixtures, Leagues)\n'
          ' - Tunomwaameni Epafras (Marketing & Communications)\n'
          'Athletes\' Rep: Magreth Mengo',
    },
    {
      'title': 'Upcoming Events',
      'content':
          'Stay tuned for upcoming local and international hockey events.\n'
          'Visit our site regularly for updates, fixtures, and tournament results.',
    },
    {
      'title': 'Sponsors',
      'content':
          'We are proudly supported by: MTC Namibia, NAMDIA, Bank Windhoek, Standard Bank, and NamibRe.',
    },
    {
      'title': 'Contact Us',
      'content':
          '📍 PO Box 25799, Post Street Mall, Windhoek, Namibia\n'
          '📧 Email: secretary@namibiahockey.org\n'
          '📞 Phone: +264 61 25438',
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
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final section = _sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section['title']!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(section['content']!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
