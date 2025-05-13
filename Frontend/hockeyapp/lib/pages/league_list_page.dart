import 'package:flutter/material.dart';
import '../services/league_service.dart';
import 'league_detail_page.dart';
import 'create_league_page.dart';

class LeagueListPage extends StatefulWidget {
  const LeagueListPage({super.key});
  @override
  State<LeagueListPage> createState() => _LeagueListPageState();
}

class _LeagueListPageState extends State<LeagueListPage> {
  List<League> _leagues = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await LeagueService().listLeagues();
      setState(() { _leagues = list; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Leagues'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final created = await Navigator.push<League>(
              c,
              MaterialPageRoute(builder: (_) => const CreateLeaguePage())
            );
            if (created != null) _load();
          },
        )
      ],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: _leagues.length,
          itemBuilder: (ctx, i) {
            final l = _leagues[i];
            return ListTile(
              title: Text(l.name),
              subtitle: Text('${l.season} • ${l.status}'),
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => LeagueDetailPage(id: l.id))
              ),
            );
          },
        ),
  );
}
