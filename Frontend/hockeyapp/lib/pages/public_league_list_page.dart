import 'package:flutter/material.dart';
import 'package:hockeyapp/pages/public_league_detail.dart';
import '../services/league_service.dart';

class PublicLeagueListPage extends StatefulWidget {
  const PublicLeagueListPage({super.key});

  @override
  State<PublicLeagueListPage> createState() => _PublicLeagueListPageState();
}

class _PublicLeagueListPageState extends State<PublicLeagueListPage> {
  List<League> _leagues = [];
  List<League> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_onSearch);
  }

  Future<void> _fetch() async {
    try {
      // hits GET localhost:8000/api/publicleagues/
      final list = await LeagueService().listPublicLeagues();
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
    appBar: AppBar(title: const Text('Leagues')),
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
                      MaterialPageRoute(builder: (_) => PublicLeagueDetail(id: l.id))
                    )
                  );
                },
              ),
            ),
          ],
        ),
  );
}
