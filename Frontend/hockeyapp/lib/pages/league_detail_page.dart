import 'package:flutter/material.dart';
import '../services/league_service.dart';

class LeagueDetailPage extends StatefulWidget {
  final int id;
  const LeagueDetailPage({required this.id, super.key});
  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  League? _league;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LeagueService().getLeague(widget.id).then((l) {
      setState(() {
        _league = l;
        _loading = false;
      });
    }).catchError((_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Failed to load')));
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('League Details')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_league!.name, style: const TextStyle(fontSize: 18)),
            Text('Season: ${_league!.season}'),
            Text('Start: ${_league!.startDate}'),
            Text('End: ${_league!.endDate}'),
            Text('Status: ${_league!.status}'),
          ]),
        ),
  );
}
