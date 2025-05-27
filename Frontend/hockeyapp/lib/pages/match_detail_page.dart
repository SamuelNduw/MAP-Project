import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:hockeyapp/services/match_service.dart';
import 'package:hockeyapp/config.dart';
import 'package:hockeyapp/theme/app_theme.dart';
import 'package:hockeyapp/pages/team_detail_page.dart';

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
    _loadPastEvents();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://${ipTestUrl}:8000/ws/match/${widget.fixtureId}/'),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      print(data);
      setState(() {
        if(data['type'] == 'score_update'){
          _liveScore = data['score'];
          _liveStatus = data['status'];
        } else{
          _events.insert(0, data);
        }
      });
    });
  }

  Future<void> _loadPastEvents() async {
    final events = await MatchService().getPastEvents(widget.fixtureId);
    setState(() {
      _events = events.reversed.toList(); // oldest first
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leadingWidth: 140,
        leading: Row(
          children: [
            const BackButton(color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                'images/logo.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              )
            )
          ],
        ),
      ),
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

          final sortedEvents = [..._events]..sort((a, b) {
            final aMinute = a['minute'] ?? 0;
            final bMinute = b['minute'] ?? 0;
            return (bMinute as int).compareTo(aMinute as int);
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    // HOME TEAM clickable avatar
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(id: m.homeTeamId),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(m.homeLogo),
                            radius: 24,
                            onBackgroundImageError: (_, __) => print("image failed to load"),
                          ),
                          const SizedBox(height: 4),
                          Text(m.homeShortName, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(score, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(status),
                      ],
                    ),
                    const Spacer(),
                    // AWAY TEAM clickable avatar
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(id: m.awayTeamId),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(m.awayLogo),
                            radius: 24,
                            onBackgroundImageError: (_, __) => print("image failed to load"),
                          ),
                          const SizedBox(height: 4),
                          Text(m.awayShortName, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Text('League: ${m.leagueName}'),
              Text('Date: ${m.date}'),
              Text('Venue: ${m.venue}'),
              const SizedBox(height: 24),
              const Text('Live Match Events:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              
              ...sortedEvents.map((e) {
                final type = (e['event_type'] ?? 'update').toString().toLowerCase();
                final minute = e['minute'] != null ? "${e['minute']}'" : '';
                final team = e['team']?['name'] ?? e['player']?['team_short_name'] ??'';
                final player = e['player']?['name'] ?? '${e['player']['first_name']} ${e['player']['last_name']}' ?? '';
                final assistant = e['assisting'] != null
                    ? '${e['assisting']['first_name']} ${e['assisting']['last_name']}'
                    : null;
                final card = e['card_type'];
                final playerIn = e['player_in']?['name'] ??
                    '${e['sub_in']?['first_name'] ?? ''} ${e['sub_in']?['last_name'] ?? ''}'.trim();
                final playerOut = e['player_out']?['name'] ??
                    '${e['sub_out']?['first_name'] ?? ''} ${e['sub_out']?['last_name'] ?? ''}'.trim();

                String title = '$type — $team';
                String subtitle = '';

                switch (type) {
                  case 'goal':
                    subtitle = '$player${assistant != null ? " (Assist: $assistant)" : ""}';
                    break;
                  case 'card':
                    subtitle = '$player — ${card?.toUpperCase()} Card';
                    break;
                  case 'substitution':
                    subtitle = '$playerOut → $playerIn';
                    break;
                  case 'injury':
                    subtitle = '$player injured';
                    break;
                  default:
                    subtitle = player;
                }

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(minute, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Icon(getEventIcon(type), size: 18)
                    ],
                  ),
                  title: Text(title[0].toUpperCase() + title.substring(1)),
                  subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  IconData getEventIcon(String type) {
    switch (type) {
      case 'goal':
        return Icons.sports_hockey;
      case 'card':
        return Icons.flag;
      case 'substitution':
        return Icons.swap_horiz;
      case 'injury':
        return Icons.healing;
      default:
        return Icons.info_outline;
    }
  }

}
