import 'package:flutter/material.dart';
import '../services/team_service.dart';

class TeamDetailPage extends StatefulWidget {
  final int id;
  const TeamDetailPage({required this.id, super.key});
  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Team? _team;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    TeamService().getTeam(widget.id).then((t) {
      setState(() {
        _team = t;
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
    appBar: AppBar(title: const Text('Team Details')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Image.network(_team!.logoUrl),
            ),
            Text(_team!.name, style: const TextStyle(fontSize: 18)),
            Text(_team!.shortName),
            Text('Founded Year - ${_team!.foundedYear}'),
          ]),
        ),
  );
}
