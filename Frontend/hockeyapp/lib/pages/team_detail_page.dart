import 'package:flutter/material.dart';
import 'package:hockeyapp/services/team_service.dart';
import 'package:hockeyapp/services/match_service.dart';
import 'package:hockeyapp/services/player_service.dart';
import 'package:hockeyapp/services/league_service.dart';

class TeamDetailPage extends StatefulWidget {
  final int id;
  const TeamDetailPage({super.key, required this.id});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Team> _teamFuture;
  late Future<List<Match>> _matchesFuture;
  late Future<List<Player>> _playersFuture;
  late Future<List<League>> _leaguesFuture;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    _teamFuture = TeamService().getTeam(widget.id);
    _matchesFuture = MatchService().listFixtures();
    _playersFuture = PlayerService().publicListPlayers();
    _leaguesFuture = LeagueService().listPublicLeagues();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Team>(
        future: _teamFuture,
        builder: (context, teamSnapshot) {
          if (teamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (teamSnapshot.hasError) {
            return Center(child: Text('Error: ${teamSnapshot.error}'));
          }
          if (!teamSnapshot.hasData) {
            return const Center(child: Text('Team not found'));
          }

          final team = teamSnapshot.data!;
          return _buildTeamProfile(team);
        },
      ),
    );
  }

  Widget _buildTeamProfile(Team team) {
    return Column(
      children: [
        // Header with gradient background
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
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Team Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          // Navigate to edit page or show edit dialog
                        },
                      ),
                    ],
                  ),
                ),
                
                // Team info section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Team logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: team.logoUrl.isNotEmpty
                              ? Image.network(
                                  team.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.sports_hockey, size: 40),
                                )
                              : const Icon(Icons.sports_hockey, size: 40),
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Team name and follow button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isFollowing ? Icons.notifications : Icons.notifications_none,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isFollowing = !_isFollowing;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isFollowing = !_isFollowing;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFollowing ? Colors.white24 : Colors.white,
                                    foregroundColor: _isFollowing ? Colors.white : Colors.blue[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(_isFollowing ? 'Following' : 'Follow'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue[800],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[800],
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Matches'),
              Tab(text: 'Squad'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(team),
              _buildMatchesTab(),
              _buildSquadTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(Team team) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Match Section
          FutureBuilder<List<Match>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              final matches = snapshot.data!;
              // Filter matches for this specific team and find next upcoming match
              final teamMatches = matches.where((m) => 
                (m.homeName == team.name || m.awayName == team.name) &&
                m.status != 'completed'
              ).toList();
              
              if (teamMatches.isEmpty) return const SizedBox();
              
              // Sort by date and get the next match
              teamMatches.sort((a, b) => a.date.compareTo(b.date));
              final nextMatch = teamMatches.first;
              
              return _buildNextMatchCard(nextMatch, team);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Team Info
          _buildInfoCard('Team Information', [
            _buildInfoRow('Founded', team.foundedYear.toString()),
            _buildInfoRow('Short Name', team.shortName),
          ]),
          
          const SizedBox(height: 16),
          
          // Leagues Section - Only show leagues this team participates in
          // Note: This would require additional API endpoint or team-league relationship data
          // For now, showing all leagues with a note that this needs team-specific filtering
          FutureBuilder<List<League>>(
            future: _leaguesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              // TODO: Filter leagues where this team participates
              // This would require either:
              // 1. A team-leagues relationship in your API
              // 2. Or filtering leagues based on matches this team plays in
              final teamLeagues = snapshot.data!; // Placeholder - needs proper filtering
              
              if (teamLeagues.isEmpty) return const SizedBox();
              
              return _buildInfoCard('Leagues', 
                teamLeagues.map((league) => 
                  _buildLeagueItem(league)
                ).toList()
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextMatchCard(Match match, Team currentTeam) {
    final isHome = match.homeName == currentTeam.name;
    final opponent = isHome ? match.awayName : match.homeName;
    final opponentShortName = isHome ? match.awayShortName : match.homeShortName;
    final opponentLogo = isHome ? match.awayLogo : match.homeLogo;
    final currentTeamLogo = isHome ? match.homeLogo : match.awayLogo;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Match',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            match.date,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Current team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: currentTeamLogo.isNotEmpty
                          ? Image.network(currentTeamLogo, fit: BoxFit.contain)
                          : const Icon(Icons.sports_hockey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentTeam.shortName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const Text(
                'vs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              
              // Opponent team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: opponentLogo.isNotEmpty
                          ? Image.network(opponentLogo, fit: BoxFit.contain)
                          : const Icon(Icons.sports_hockey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      opponentShortName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueItem(League league) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              league.status,
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  league.season,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return FutureBuilder<Team>(
      future: _teamFuture,
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final currentTeam = teamSnapshot.data!;
        
        return FutureBuilder<List<Match>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading matches: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No matches found'));
            }

            // Filter matches for this specific team only
            final teamMatches = snapshot.data!.where((match) =>
                match.homeName == currentTeam.name || match.awayName == currentTeam.name).toList();

            if (teamMatches.isEmpty) {
              return const Center(child: Text('No matches found for this team'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teamMatches.length,
              itemBuilder: (context, index) {
                final match = teamMatches[index];
                return _buildMatchCard(match);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
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
          Text(
            match.leagueName,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
                      child: match.homeLogo.isNotEmpty
                          ? Image.network(match.homeLogo, fit: BoxFit.contain)
                          : const Icon(Icons.sports_hockey, size: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.homeShortName,
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
                  if (match.status == 'completed')
                    Text(
                      match.scoreDisplay,
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
                      color: match.status == 'completed' ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      match.status.toUpperCase(),
                      style: TextStyle(
                        color: match.status == 'completed' ? Colors.green[800] : Colors.orange[800],
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
                      child: match.awayLogo.isNotEmpty
                          ? Image.network(match.awayLogo, fit: BoxFit.contain)
                          : const Icon(Icons.sports_hockey, size: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      match.awayShortName,
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
            match.date,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadTab() {
    return FutureBuilder<List<Player>>(
      future: _playersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading squad: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No players found'));
        }

        // Filter players for this specific team only
        final teamPlayers = snapshot.data!.where((player) =>
            player.id == widget.id).toList();

        if (teamPlayers.isEmpty) {
          return const Center(child: Text('No players found for this team'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teamPlayers.length,
          itemBuilder: (context, index) {
            final player = teamPlayers[index];
            return _buildPlayerCard(player);
          },
        );
      },
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
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
      child: Row(
        children: [
          // Jersey number
          if (player.jerseyNo != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  player.jerseyNo.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (player.jerseyNo != null) const SizedBox(width: 16),
          
          // Player photo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey[200],
            ),
            child: player.photo != null && player.photo!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      player.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 30),
                    ),
                  )
                : const Icon(Icons.person, size: 30),
          ),
          
          const SizedBox(width: 16),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.firstName} ${player.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (player.position != null)
                  Text(
                    player.position!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                Text(
                  player.nationality,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Player stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (player.heightCm != null)
                Text(
                  '${player.heightCm}cm',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              if (player.weightKg != null)
                Text(
                  '${player.weightKg}kg',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}