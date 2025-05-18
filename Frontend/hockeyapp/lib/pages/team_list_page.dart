import 'package:flutter/material.dart';
import '../services/team_service.dart';
import 'team_detail_page.dart';
import 'create_team_page.dart';

class TeamListPage extends StatefulWidget {
  const TeamListPage({super.key});
  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  List<Team> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await TeamService().listTeams();
      setState(() { _teams = list; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Teams'),
      leadingWidth: 140,
      leading: Row(
        children: [
          const BackButton(),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final created = await Navigator.push<Team>(
              c,
              MaterialPageRoute(builder: (_) => const CreateTeamPage())
            );
            if (created != null) _load();
          },
        )
      ],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: _teams.length,
          itemBuilder: (ctx, i) {
            final t = _teams[i];
            return ListTile(
              title: Text('${t.name} • ${t.shortName}'),
              subtitle: Text('founded - ${t.foundedYear}'),
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => TeamDetailPage(id: t.id))
              ),
            );
          },
        ),
  );
}
