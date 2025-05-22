import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:hockeyapp/services/match_service.dart';

class MatchDetailPage extends StatefulWidget {
  final int fixtureId;
  const MatchDetailPage({super.key, required this.fixtureId});
  @override State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  late Future<Match> _futureMatch;
  late WebSocketChannel _channel;

  String? _liveScore;
  String? _liveStatus;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _futureMatch = MatchService().getFixture(widget.fixtureId);

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000/ws/match/${widget.fixtureId}/'),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        if (data.containsKey('score')){
          _liveScore = data['score'];
        } 
        if(data.containsKey('status')){
          _liveStatus = data['status'];
        }
        _events.insert(0, data);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          final score = _liveScore ?? m.scoreDisplay;
          final status = _liveStatus ?? m.status;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Column(children: [
                      CircleAvatar(backgroundImage: NetworkImage(m.homeLogo), radius: 24, onBackgroundImageError: (_, __) => print("image failed to load"),),
                      const SizedBox(height: 4),
                      Text(m.homeShortName, overflow: TextOverflow.ellipsis),
                    ]),
                    const Spacer(),
                    Column(children: [
                      Text(score, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(status),
                    ]),
                    const Spacer(),
                    Column(children: [
                      CircleAvatar(backgroundImage: NetworkImage(m.awayLogo), radius: 24, onBackgroundImageError: (_, __) => print("image failed to load"),),
                      const SizedBox(height: 4),
                      Text(m.awayShortName, overflow: TextOverflow.ellipsis),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Text('League: ${m.leagueName}'),
              Text('Date: ${m.date}'),
              Text('Venue: ${m.venue}'),
              const SizedBox(height: 24),
              const Text('Live Match Events:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ..._events.map((e) => ListTile(
                title: Text('${e['event_type'] ?? 'Update'} at ${e['minute'] ?? '-'}\''),
                subtitle: e.containsKey('player') ? Text(e['player']) : null,
              )),
            ],
          );
        },
      ),
    );
  }
}
