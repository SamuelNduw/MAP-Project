import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF005A8D);
    const white = Colors.white;
    const avatarSize = 80.0;

    Widget statCard(String label, String value) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // right‐side menu
      endDrawer: Drawer(child: Container(color: blue)),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png',
              width: 80, height: 80, fit: BoxFit.contain),
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // blue header (unchanged)...
            Container(
              color: blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Max',
                            style: TextStyle(
                                color: white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300)),
                        const Text('Aarons',
                            style: TextStyle(
                                color: white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: Colors.grey[400],
                              ),
                              const SizedBox(width: 6),
                              const Text('Shooting Stars',
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person,
                        size: avatarSize, color: Colors.white),
                  ),
                ],
              ),
            ),

            // white info card (unchanged)...
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _InfoTile(title: 'Forward', subtitle: 'Position'),
                      _InfoTile(title: 'Namibia', subtitle: 'Country'),
                      _InfoTile(title: '28', subtitle: 'Age'),
                    ],
                  ),
                ),
              ),
            ),

            // ─── 2×2 Stats Grid ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  statCard('Appearances', '93'),
                  statCard('Goals', '29'),
                  statCard('Wins', '56'),
                  statCard('Losses', '28'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Teams History Card (no Expanded) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Teams',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      _TeamRow(
                          name: 'Shooting Stars', period: 'Jul 2022 - now'),
                      _TeamRow(
                          name: 'Red Ninjas', period: 'Oct 2020 - Jul 2022'),
                      _TeamRow(
                          name: 'Windhoek Shields',
                          period: 'Sept 2019 - Oct 2020'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title, subtitle;
  const _InfoTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name, period;
  const _TeamRow({required this.name, required this.period});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          Text(period, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
