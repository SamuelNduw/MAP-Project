// lib/pages/matches_page.dart

import 'package:flutter/material.dart';
import 'package:hockeyapp/services/match_service.dart';
import 'package:hockeyapp/pages/match_detail_page.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});
  @override State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  late Future<List<Match>> _fixtures;
  @override void initState() {
    super.initState();
    _fixtures = MatchService().listFixtures();
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: FutureBuilder<List<Match>>(
        future: _fixtures,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final matches = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (ctx, i) {
              final m = matches[i];
              return InkWell(
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => MatchDetailPage(fixtureId: m.id),
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      CircleAvatar(backgroundImage: NetworkImage(m.homeLogo)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m.homeShortName, overflow: TextOverflow.ellipsis)),
                      Column(children: [
                        Text(m.scoreDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(m.status, style: TextStyle(color: m.status=='FINISHED' ? Colors.green : Colors.orange)),
                      ]),
                      Expanded(child: Text(m.awayShortName, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      CircleAvatar(backgroundImage: NetworkImage(m.awayLogo)),
                    ]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
