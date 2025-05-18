// lib/pages/match_detail_page.dart

import 'package:flutter/material.dart';
import 'matches_page.dart'; // for MatchInfo

class MatchDetailPage extends StatelessWidget {
  final MatchInfo match;
  const MatchDetailPage({required this.match, super.key});

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    const blue = Color(0xFF005A8D);

    return Scaffold(
      endDrawer: Drawer(child: Container(color: blue)),
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Match Details',
            style: TextStyle(color: Colors.black)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png',
              height: 40, fit: BoxFit.contain),
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
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header Card ─────────────────────────────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Home – Time Pill – Score Pill – Away
                  SizedBox(
                    height: 56,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _teamColumn(match.homeLogo, match.homeName),

                        const Spacer(),

/*
                        // Time pill
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black54),
                              ),
                              child: Text(
                                match.time,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
*/
                        const SizedBox(width: 12),

                        
                        // Score pill
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                match.score,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        _teamColumn(match.awayLogo, match.awayName),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Series info
                  Text(
                    'Eastern Conference Semifinal · Playoffs · NHL',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Tabs: GAME STATS & BOX SCORE ─────────────────
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: blue,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: blue,
                  tabs: const [
                    Tab(text: 'GAME STATS'),
                    Tab(text: 'BOX SCORE'),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _buildGameStats(),
                      Center(
                        child: Text(
                          'Box Score coming soon',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamColumn(String logoPath, String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(logoPath, width: 32, height: 32, fit: BoxFit.contain),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGameStats() {
    final stats = <_StatRow>[
      const _StatRow(label: 'Points', left: '18', right: '3'),
      const _StatRow(label: 'Penalties', left: '12', right: '11'),
      const _StatRow(label: 'Penalty minutes', left: '40', right: '30'),
      const _StatRow(label: 'Power-play goals', left: '1', right: '0'),
      const _StatRow(label: 'Short-handed goals', left: '0', right: '0'),
      const _StatRow(label: 'Saves', left: '31', right: '26'),
      const _StatRow(label: 'Hits', left: '18', right: '3'),
      const _StatRow(label: 'Giveaways', left: '10', right: '21'),
      const _StatRow(label: 'Takeaways', left: '5', right: '4'),
      const _StatRow(label: 'Faceoffs won', left: '31', right: '28'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => stats[i],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, left, right;
  const _StatRow({
    required this.label,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(left, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),

        // label centered in its slot:
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),

        const SizedBox(width: 8),
        Text(right, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
