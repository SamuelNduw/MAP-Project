import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hockeyapp/config.dart';
import 'package:hockeyapp/pages/match_detail_page.dart';

class PublicLeagueDetail extends StatefulWidget {
  final int id;
  const PublicLeagueDetail({super.key, required this.id});

  @override
  State<PublicLeagueDetail> createState() => _PublicLeagueDetailState();
}

class _PublicLeagueDetailState extends State<PublicLeagueDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  Map<String, dynamic>? _league;
  List<Map<String, dynamic>> _teams = [];

  List<Map<String, dynamic>> _fixtures = [];
  bool _loadingFixtures = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLeagueAndTeams();
    _fetchFixtures();
  }

  Future<void> _fetchLeagueAndTeams() async {
    try {
      final res = await Dio().get('${apiBaseUrl}publicleagues/${widget.id}/');
      final leagueData = res.data;

      List<Map<String, dynamic>> teams = [];

      for (var teamId in leagueData['teams']) {
        final teamRes = await Dio().get('${apiBaseUrl}publicteams/$teamId/');
        teams.add(teamRes.data);
      }

      setState(() {
        _league = leagueData;
        _teams = teams;
        _loading = false;
      });
    } catch (e) {
      print('Failed to load league or teams: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchFixtures() async {
  try {
    final res = await Dio().get(
      '${apiBaseUrl}publicfixtures/',
      queryParameters: {'league_id': widget.id},
    );

    setState(() {
      _fixtures = List<Map<String, dynamic>>.from(res.data);
      _loadingFixtures = false;
    });
  } catch (e) {
    print('Error loading fixtures: $e');
    setState(() => _loadingFixtures = false);
  }
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
        title: Text(_league?['name'] ?? 'League Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Standings'),
            Tab(text: 'Fixtures'),
            Tab(text: 'Teams'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Standings coming soon...')),
          _buildFixturesTab(),
          _buildTeamsTab(),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    if (_teams.isEmpty) {
    return const Center(child: Text('No teams found.'));
  }

  return Padding(
    padding: const EdgeInsets.all(8),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two cards per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  team['logo_url'] ?? '',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      team['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Founded: ${team['founded_year']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

}

  Widget _buildFixturesTab() {
  if (_loadingFixtures) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_fixtures.isEmpty) {
    return const Center(child: Text('No fixtures available.'));
  }

  return ListView.builder(
    itemCount: _fixtures.length,
    itemBuilder: (context, index) {
      final fx = _fixtures[index];

      final home = fx['home_team']?['short_name'] ?? fx['home_team']?['name'] ?? 'Home';
      final away = fx['away_team']?['short_name'] ?? fx['away_team']?['name'] ?? 'Away';
      final homeLogo = fx['home_team']?['logo_url'];
      final awayLogo = fx['away_team']?['logo_url'];

      final matchScore = fx['score'];
      final score = (matchScore != null)
          ? '$matchScore'
          : 'vs';

      final date = fx['match_datetime'] ?? 'Unknown date';
      final venue = fx['venue'] ?? 'Unknown venue';
      final status = fx['status'] ?? 'Unknown status';

      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchDetailPage(fixtureId: fx['id']),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Row with logos and names
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (homeLogo != null)
                      Image.network(
                        homeLogo,
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 32),
                      ),
                    const SizedBox(width: 8),
                    Text(home, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(score, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(away, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    if (awayLogo != null)
                      Image.network(
                        awayLogo,
                        width: 48,
                        height: 48,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 32),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 4),
                Text(
                  '$status $date at $venue',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      );

    },
  );
}




  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
