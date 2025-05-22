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
  List<League> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _load() async {
    try {
      final list = await LeagueService().listLeagues();
      setState(() { 
        _leagues = list; 
        _filtered = list;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _leagues
          .where((l) => l.name.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Leagues'),
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
      : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Find leagues',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final l = _filtered[i];
                  return ListTile(
                    title: Text(l.name),
                    subtitle: Text(l.season),
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => LeagueDetailPage(id: l.id))
                    )
                  );
                },
              ),
            ),
          ],
        ),
  );
}
