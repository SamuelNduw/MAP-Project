// lib/pages/matches_page.dart

import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  // Sample data model now includes both time and score
  static final Map<String, List<MatchInfo>> _matchesByDate = {
    'Friday 16 May': [
      MatchInfo(
        homeName: 'Saints Hockey',
        homeLogo: 'images/saints.png',
        awayName: 'Team-X',
        awayLogo: 'images/Team-X.jpg',
        time: '20:30',
        score: '3–2',
      ),
      MatchInfo(
        homeName: 'Flying Eagles',
        homeLogo: 'images/saints.png',
        awayName: 'Desert Foxes',
        awayLogo: 'images/Team-X.jpg',
        time: '18:00',
        score: '1–1',
      ),
    ],
    'Saturday 17 May': [
      MatchInfo(
        homeName: 'Shields United',
        homeLogo: 'images/saints.png',
        awayName: 'Raiders FC',
        awayLogo: 'images/Team-X.jpg',
        time: '16:45',
        score: '0–4',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    const blue = Color(0xFF005A8D);

    return Scaffold(
      endDrawer: Drawer(child: Container(color: blue)),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        centerTitle: true,
        title: const Text('Matches', style: TextStyle(color: Colors.black)),
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

          // For each date group
          for (var entry in _matchesByDate.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Each match row
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
  final String time;   // kick-off
  final String score;  // final score

  const MatchInfo({
    required this.homeName,
    required this.homeLogo,
    required this.awayName,
    required this.awayLogo,
    required this.time,
    required this.score,
  });
}

class _MatchRow extends StatelessWidget {
  final MatchInfo match;
  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    // Home block
    final homeBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            match.homeName,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),            // tightened
        Image.asset(match.homeLogo, width: 20, height: 20),
      ],
    );

    // Time pill wrapped in a fixed-width box and centered
    final timePill = SizedBox(
      width: 70,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black54),
          ),
          child: Text(
            match.time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    /*
    // Score pill
    final scorePill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        match.score,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
    */

    // Away block
    final awayBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(match.awayLogo, width: 20, height: 20),
        const SizedBox(width: 4),            // tightened
        Flexible(
          child: Text(
            match.awayName,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

      return Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/fan/matches/detail',
                arguments: match,
              );
            },
            child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Place home on left edge
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: homeBlock,
                    ),
                  ),

                  // small gap before the time pill
                  const SizedBox(width: 4),

                  // Time pill centered at middle
                  timePill,

                  // small gap after the time pill
                  const SizedBox(width: 4),

                  /*
                  Center(child: scorePill),
                  const SizedBox(width: 8),
                  */

                  // Place away on right edge
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: awayBlock,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, height: 1),
        ],
      );
  }
}
