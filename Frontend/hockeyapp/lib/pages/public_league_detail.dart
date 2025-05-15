import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLeagueAndTeams();
  }

  Future<void> _fetchLeagueAndTeams() async {
    try {
      final res = await Dio().get('http://10.0.2.2:8000/api/publicleagues/${widget.id}/');
      final leagueData = res.data;

      List<Map<String, dynamic>> teams = [];

      for (var teamId in leagueData['teams']) {
        final teamRes = await Dio().get('http://10.0.2.2:8000/api/publicteams/$teamId/');
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
            Tab(text: 'Fixtures'),
            Tab(text: 'Teams'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Fixtures coming soon...')),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
