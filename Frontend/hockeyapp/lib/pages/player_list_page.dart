import 'package:flutter/material.dart';
import 'package:hockeyapp/pages/create_player_page.dart';
import 'package:hockeyapp/pages/update_player_page.dart';
import 'package:hockeyapp/services/player_service.dart';
import '../theme/app_theme.dart';

class PlayerListPage extends StatefulWidget {
  const PlayerListPage({super.key});

  @override
  State<PlayerListPage> createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage> {
  List<Player> _players = [];
  List<Player> _filtered = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered =
          _players
              .where(
                (p) =>
                    '${p.firstName} ${p.lastName}'.toLowerCase().contains(
                      query,
                    ) ||
                    (p.teamShortName?.toLowerCase().contains(query) ?? false) ||
                    (p.position?.toLowerCase().contains(query) ?? false),
              )
              .toList();
    });
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final players = await PlayerService().publicListPlayers();
      setState(() {
        _players = players;
        _filtered = players;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 1,
        title: const Text('Players', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePlayerPage(),
                ),
              );
              if (result == true) {
                _loadPlayers();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'images/logo.png',
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search players...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              onPressed: _loadPlayers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(child: Text('No players found'));
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final player = _filtered[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePlayerPage(player: player),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          player.photo != null && player.photo!.isNotEmpty
                              ? NetworkImage(player.photo!)
                              : null,
                      child:
                          player.photo == null || player.photo!.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${player.firstName} ${player.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Team: ${player.teamShortName ?? "Unknown"}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Position: ${_getPositionName(player.position ?? "")}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPositionName(String code) {
    switch (code) {
      case 'GK':
        return 'Goalkeeper';
      case 'D':
        return 'Defender';
      case 'M':
        return 'Midfielder';
      case 'F':
        return 'Forward';
      default:
        return code;
    }
  }
}
