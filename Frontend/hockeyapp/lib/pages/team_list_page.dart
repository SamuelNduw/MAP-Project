import 'package:flutter/material.dart';
import '../services/team_service.dart';
import 'team_detail_page.dart';
import 'create_team_page.dart';
import '../theme/app_theme.dart';

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
      setState(() {
        _teams = list;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
        leadingWidth: 140,
        leading: Row(
          children: [
            const BackButton(color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                'images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<Team>(
            context,
            MaterialPageRoute(builder: (_) => const CreateTeamPage()),
          );
          if (created != null) _load();
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _teams.isEmpty
              ? const Center(child: Text("No teams found"))
              : ListView.builder(
                itemCount: _teams.length,
                itemBuilder: (ctx, i) {
                  final t = _teams[i];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        '${t.name} • ${t.shortName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Founded: ${t.foundedYear}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap:
                          () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => TeamDetailPage(id: t.id),
                            ),
                          ),
                    ),
                  );
                },
              ),
    );
  }
}
