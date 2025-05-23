import 'package:flutter/material.dart';
import '../services/league_service.dart';
import 'league_detail_page.dart';
import 'create_league_page.dart';
import '../theme/app_theme.dart';

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
      _filtered =
          _leagues.where((l) => l.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Leagues', style: TextStyle(color: Colors.white)),
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
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final created = await Navigator.push<League>(
                context,
                MaterialPageRoute(builder: (_) => const CreateLeaguePage()),
              );
              if (created != null) _load();
            },
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search leagues',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filtered.isEmpty
                            ? const Center(child: Text('No leagues found'))
                            : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (ctx, i) {
                                final l = _filtered[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    title: Text(
                                      l.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    subtitle: Text('Season: ${l.season}'),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    LeagueDetailPage(id: l.id),
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
