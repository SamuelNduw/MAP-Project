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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
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
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _teams.length,
                itemBuilder: (ctx, i) {
                  final t = _teams[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        '${t.name} • ${t.shortName}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Founded: ${t.foundedYear}',
                        style: textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
