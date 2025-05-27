import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hockeyapp/config.dart';
import 'package:hockeyapp/pages/match_detail_page.dart';
import 'package:hockeyapp/pages/team_detail_page.dart';

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

  List<Map<String, dynamic>> _standings = [];
  bool _loadingStandings = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLeagueAndTeams();
    _fetchFixtures();
    _fetchStandings();
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

  Future<void> _fetchStandings() async {
    try {
      final res = await Dio().get(
        '${apiBaseUrl}publicleaguestandings/',
        queryParameters: {'league_id': widget.id},
      );
      setState(() {
        _standings = List<Map<String, dynamic>>.from(res.data);
        _loadingStandings = false;
      });
    } catch (e) {
      print('Error loading standings: $e');
      setState(() => _loadingStandings = false);
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
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context)
                        ),
                        const Expanded(
                          child: Text('League Details', style:TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,)) 
                        )
                      ]
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_league?['name'] ?? 'League Details', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text("Season ${_league?['season'] ?? ''}", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
                                  Text(" - ${_league?['status'] ?? ''}", style: TextStyle(color: Colors.grey))
                                ],
                              )
                            ],
                          )
                        )
                      ]
                    )
                  )
                ],
              )
            ),

          ),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[800],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[800],
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Standings'),
                Tab(text: 'Matches'),
                Tab(text: 'Teams'),
              ]
            )
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStandingsTab(),
                _buildFixturesTab(),
                _buildTeamsTab(),
              ],
            ) 
          )
        ],
      )
    );
  }

  Widget _buildStandingsTab() {
    if (_loadingStandings) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_standings.isEmpty) {
      return const Center(child: Text('No standings available.'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3)
              )
            ]
          ),
          child: DataTable(
            columnSpacing: 12,
            headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Team')),
              DataColumn(label: Text('P')),
              DataColumn(label: Text('W')),
              DataColumn(label: Text('D')),
              DataColumn(label: Text('L')),
              DataColumn(label: Text('GF')),
              DataColumn(label: Text('GA')),
              DataColumn(label: Text('Pts')),
            ],
            rows: _standings.map((team) {
              return DataRow(
                cells: [
                  DataCell(Text(team['position'].toString())),
                  DataCell(Row(
                    children: [
                      if (team['team_logo_url'] != null && team['team_logo_url'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(team['team_logo_url'], width: 28, height: 28, errorBuilder: (_, __, ___) => Icon(Icons.image, size: 20)),
                        ),
                      Text(team['team_short_name'] ?? team['team_name']),
                    ],
                  )),
                  DataCell(Text(team['played'].toString())),
                  DataCell(Text(team['wins'].toString())),
                  DataCell(Text(team['draws'].toString())),
                  DataCell(Text(team['losses'].toString())),
                  DataCell(Text(team['goals_for'].toString())),
                  DataCell(Text(team['goals_against'].toString())),
                  DataCell(Text(team['points'].toString())),
                ],
              );
            }).toList(),
          ),
        )
        ]
      )
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
        return InkWell(
          borderRadius: BorderRadius.circular(12), // match Card radius for ripple
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeamDetailPage(id: team['id']),
              ),
            );
          },
          child: Card(
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
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical:4),
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: homeLogo.isNotEmpty
                              ? Image.network(homeLogo, fit: BoxFit.contain)
                              : const Icon(Icons.sports_hockey, size: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          home,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Score or VS
                  Column(
                    children: [
                      if (status == 'FINISHED' || status == 'LIVE')
                        Text(
                          score,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'vs',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'completed' ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'completed' ? Colors.green[800] : Colors.orange[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: awayLogo.isNotEmpty
                              ? Image.network(awayLogo, fit: BoxFit.contain)
                              : const Icon(Icons.sports_hockey, size: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          away,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
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
