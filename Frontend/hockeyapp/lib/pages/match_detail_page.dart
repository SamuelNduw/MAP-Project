// lib/pages/match_detail_page.dart

import 'package:flutter/material.dart';
import 'package:hockeyapp/services/match_service.dart';

class MatchDetailPage extends StatefulWidget {
  final int fixtureId;
  const MatchDetailPage({super.key, required this.fixtureId});
  @override State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  late Future<Match> _futureMatch;
  @override void initState() {
    super.initState();
    _futureMatch = MatchService().getFixture(widget.fixtureId);
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: FutureBuilder<Match>(
        future: _futureMatch,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final m = snap.data!;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Column(children: [
                    CircleAvatar(backgroundImage: NetworkImage(m.homeLogo), radius: 24),
                    const SizedBox(height: 4),
                    Text(m.homeShortName, overflow: TextOverflow.ellipsis),
                  ]),
                  const Spacer(),
                  Column(children: [
                    Text(m.scoreDisplay, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(m.status),
                  ]),
                  const Spacer(),
                  Column(children: [
                    CircleAvatar(backgroundImage: NetworkImage(m.awayLogo), radius: 24),
                    const SizedBox(height: 4),
                    Text(m.awayShortName, overflow: TextOverflow.ellipsis),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            Text('League: ${m.leagueName}'),
            Text('Date: ${m.date}'),
            Text('Venue: ${m.leagueName}'),
          ]);
        },
      ),
    );
  }
}
