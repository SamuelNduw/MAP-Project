import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  // Sample data model
  static final Map<String, List<MatchInfo>> _matchesByDate = {
    'Friday 16 May': [
      MatchInfo(
        homeName: 'Saints Hockey',
        homeLogo: 'images/saints.png',
        awayName: 'Wanderers Windhoek',
        awayLogo: 'images/wanderers.png',
        time: '20:30',
      ),
      MatchInfo(
        homeName: 'Saints Hockey',
        homeLogo: 'images/saints.png',
        awayName: 'Wanderers Windhoek',
        awayLogo: 'images/wanderers.png',
        time: '20:30',
      ),
    ],
    'Saturday 17 May': [
      MatchInfo(
        homeName: 'Saints Hockey',
        homeLogo: 'images/saints.png',
        awayName: 'Wanderers Windhoek',
        awayLogo: 'images/wanderers.png',
        time: '20:30',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;

    return Scaffold(
      // right‐side menu drawer
      endDrawer: Drawer(child: Container(color: const Color(0xFF005A8D))),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        centerTitle: true,
        title: const Text(
          'Matches',
          style: TextStyle(color: Colors.black),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'images/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Builder(builder: (ctx) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            );
          }),
          const SizedBox(width: 16),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Center(
            child: Text(
              'Matches',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Build each date group
          for (var entry in _matchesByDate.entries) ...[
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Matches under that date
            ...entry.value.map((m) => _MatchRow(match: m)).toList(),

            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class MatchInfo {
  final String homeName, homeLogo;
  final String awayName, awayLogo;
  final String time;
  const MatchInfo({
    required this.homeName,
    required this.homeLogo,
    required this.awayName,
    required this.awayLogo,
    required this.time,
  });
}

class _MatchRow extends StatelessWidget {
  final MatchInfo match;
  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Home team
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        match.homeName,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(match.homeLogo, width: 24, height: 24),
                  ],
                ),
              ),

              // Time pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black54),
                ),
                child: Text(
                  match.time,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),

              // Away team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(match.awayLogo, width: 24, height: 24),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        match.awayName,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
