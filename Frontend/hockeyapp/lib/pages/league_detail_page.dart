import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';

import '../services/team_service.dart';

class LeagueDetailPage extends StatefulWidget {
  final int id;
  const LeagueDetailPage({super.key, required this.id});

  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _storage = const FlutterSecureStorage();
  bool _loading = true, _saving = false, _adding = false;

  // League info controllers
  final _nameCtrl = TextEditingController();
  final _seasonCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  String _status = 'SCHEDULED';

  // Teams
  List<Team> _leagueTeams = [];
  List<Team> _allTeams = [];
  int? _selectedTeamId;

  // Fixtures
  List<Map<String, dynamic>> _fixtures = [];
  bool _loadingFixtures = true, _addingFixture = false;

  // Controllers for new‐fixture form
  int? _homeTeamId, _awayTeamId;
  DateTime? _matchDate;
  final _venueCtrl = TextEditingController();

   @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
    _loadFixtures();
  }

  Future<Dio> _createAuthDio() async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await _storage.read(key: 'accessToken');
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    try {
      final dio = await _createAuthDio();

      // 1) fetch league JSON (includes teams: [id,...])
      final resp = await dio.get('admin/leagues/${widget.id}/');
      final data = resp.data as Map<String, dynamic>;
      _nameCtrl.text = data['name'];
      _seasonCtrl.text = data['season'];
      _startCtrl.text = data['start_date'];
      _endCtrl.text = data['end_date'];
      _status = data['status'];

      final List<dynamic> teamIds = data['teams'] ?? [];

      // 2) fetch team details for league
      final ts = TeamService();
      _leagueTeams = await Future.wait(teamIds.map((tid) => ts.getTeam(tid)));

      // 3) fetch all teams for dropdown
      _allTeams = await ts.listTeams();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to load data')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveInfo() async {
    setState(() => _saving = true);
    try {
      final dio = await _createAuthDio();
      final resp = await dio.patch(
        'admin/leagues/${widget.id}/',
        data: {
          'name': _nameCtrl.text,
          'season': _seasonCtrl.text,
          'start_date': _startCtrl.text,
          'end_date': _endCtrl.text,
          'status': _status,
        },
      );
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('League updated')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Update failed')));
    } finally {
      setState(() => _saving = false);
      _loadAll(); // refresh
    }
  }

  Future<void> _addTeam() async {
    if (_selectedTeamId == null) return;
    setState(() => _adding = true);
    try {
      final dio = await _createAuthDio();
      final resp = await dio.post(
        'admin/leagues/add-team/',
        data: {
          'league': widget.id,
          'team': _selectedTeamId,
        },
      );
      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Team added')));
        _selectedTeamId = null;
        _loadAll();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _adding = false);
    }
  }

  Future<void> _loadFixtures() async {
    setState(() => _loadingFixtures = true);
    try {
      final dio = await _createAuthDio();
      final resp = await dio.get(
        'admin/fixtures/',
        queryParameters: {'league_id': widget.id},
      );
      setState(() {
        _fixtures = List<Map<String, dynamic>>.from(resp.data);
      });
    } catch (e) {
      // handle error…
    } finally {
      setState(() => _loadingFixtures = false);
    }
  }

  Future<void> _addFixture() async {
    if (_homeTeamId == null || _awayTeamId == null || _matchDate == null) return;
    setState(() => _addingFixture = true);
    try {
      final dio = await _createAuthDio();
      await dio.post('admin/fixtures/', data: {
        'league_id': widget.id,
        'home_team_id': _homeTeamId,
        'away_team_id': _awayTeamId,
        'match_datetime': _matchDate!.toIso8601String().split('T').first,
        'venue': _venueCtrl.text,
      });
      await _loadFixtures();
    } catch (e) {
      // handle error…
    } finally {
      setState(() => _addingFixture = false);
    }
  }

  Future<void> _updateScore(int fixtureId, int homeScore, int awayScore, String status) async {
    final dio = await _createAuthDio();
    await dio.post(
      'admin/fixtures/$fixtureId/update_score/',
      data: {
        'home_team_score': homeScore,
        'away_team_score': awayScore,
        'status': status,
      },
    );
    await _loadFixtures();
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('League Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Fixtures'),
            Tab(text: 'Info'),
            Tab(text: 'Teams'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ── Add Fixture Form ───────────────────────
                ExpansionTile(
                  title: const Text('Add New Fixture'),
                  children: [
                    DropdownButtonFormField<int>(
                      hint: const Text('Home Team'),
                      value: _homeTeamId,
                      items: _leagueTeams
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _homeTeamId = v),
                    ),
                    DropdownButtonFormField<int>(
                      hint: const Text('Away Team'),
                      value: _awayTeamId,
                      items: _leagueTeams
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _awayTeamId = v),
                    ),
                    ListTile(
                      title: Text(
                        _matchDate == null
                            ? 'Select Date'
                            : 'Date: ${_matchDate!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _matchDate = d);
                      },
                    ),
                    TextField(
                      controller: _venueCtrl,
                      decoration: const InputDecoration(labelText: 'Venue'),
                    ),
                    const SizedBox(height: 8),
                    _addingFixture
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _addFixture,
                            child: const Text('Create Fixture'),
                          ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── List Fixtures ───────────────────────────
                _loadingFixtures
                    ? const Expanded(child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _fixtures.length,
                          itemBuilder: (ctx, i) {
                            final fx = _fixtures[i];
                            // inside your ListView.builder in _buildFixturesTab:
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '${fx['home_team']['short_name']} vs ${fx['away_team']['short_name']}'
                                ),
                                subtitle: Text(
                                  '${fx['match_datetime']} @ ${fx['venue']} — ${fx['status']}'
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Create controllers with the current scores
                                    // final homeCtrl = TextEditingController(
                                    //   text: fx['home_team_score']?.toString() ?? '0'
                                    // );
                                    // final awayCtrl = TextEditingController(
                                    //   text: fx['away_team_score']?.toString() ?? '0'
                                    // );

                                    // String selectedStatus = fx['status'] ?? 'UPCOMING';

                                    showDialog(
  context: context,
  builder: (_) {
    String selectedStatus = fx['status'] ?? 'UPCOMING';
    final homeCtrl = TextEditingController(
        text: fx['home_team_score']?.toString() ?? '0');
    final awayCtrl = TextEditingController(
        text: fx['away_team_score']?.toString() ?? '0');

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Update Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${fx['home_team']['short_name']} vs ${fx['away_team']['short_name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: homeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Home Score'),
            ),
            TextField(
              controller: awayCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Away Score'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                // DropdownMenuItem(value: 'SCHEDULED', child: Text('Scheduled')),
                DropdownMenuItem(value: 'UPCOMING', child: Text('Upcoming')),
                DropdownMenuItem(value: 'LIVE', child: Text('Live')),
                DropdownMenuItem(value: 'FINISHED', child: Text('Finished')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedStatus = val);
                }
              },
              decoration: const InputDecoration(labelText: 'Match Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final h = int.tryParse(homeCtrl.text) ?? 0;
              final a = int.tryParse(awayCtrl.text) ?? 0;
              await _updateScore(fx['id'], h, a, selectedStatus);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  },
);

                                  },
                                ),
                              ),
                            );

                          },
                        ),
                      ),
              ],
            ),
          ),
          // ── Info Tab ────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _seasonCtrl,
                  decoration: const InputDecoration(labelText: 'Season'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _startCtrl,
                  decoration: const InputDecoration(labelText: 'Start Date'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _endCtrl,
                  decoration: const InputDecoration(labelText: 'End Date'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'SCHEDULED', child: Text('Scheduled')),
                    DropdownMenuItem(value: 'RUNNING', child: Text('Running')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 20),
                _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveInfo,
                        child: const Text('Save Changes'),
                      ),
              ],
            ),
          ),

          // ── Teams Tab ───────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Add team dropdown + button
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        hint: const Text('Select team to add'),
                        value: _selectedTeamId,
                        items: _allTeams
                            .where((t) =>
                                !_leagueTeams.any((lt) => lt.id == t.id))
                            .map((t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTeamId = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _adding
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _addTeam, child: const Text('Add')),
                  ],
                ),
                const SizedBox(height: 12),

                // Team cards grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _leagueTeams.length,
                    itemBuilder: (context, i) {
                      final team = _leagueTeams[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                team.logoUrl,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              team.name,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Founded: ${team.foundedYear}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
