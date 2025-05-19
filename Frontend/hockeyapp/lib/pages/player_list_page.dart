import 'package:flutter/material.dart';
import 'package:hockeyapp/pages/create_player_page.dart';
import 'package:hockeyapp/pages/update_player_page.dart';
import 'package:hockeyapp/services/player_service.dart';

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
      _filtered = _players.where((p) =>
        '${p.firstName} ${p.lastName}'.toLowerCase().contains(query) ||
        (p.teamShortName?.toLowerCase().contains(query) ?? false) ||
        (p.position?.toLowerCase().contains(query) ?? false)).toList();
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
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const CreatePlayerPage()),
              );
              if (result == true) {
                _loadPlayers();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(player.photo ?? ''),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${player.firstName} ${player.lastName}', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
                          Text('Team: ${player.teamShortName ?? "Unknown"}'),
                          Text('Position: ${player.position ?? "N/A"}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerListItem({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: player.photo != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(player.photo!),
                radius: 24,
              )
            : const CircleAvatar(
                child: Icon(Icons.person),
                radius: 24,
              ),
        title: Text('${player.firstName} ${player.lastName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (player.position != null) Text('Position: ${_getPositionName(player.position!)}'),
            if (player.jerseyNo != null) Text('Jersey: #${player.jerseyNo}'),
            Text('Team ID: ${player.teamId}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _getPositionName(String positionCode) {
    switch (positionCode) {
      case 'GK':
        return 'Goalkeeper';
      case 'D':
        return 'Defender';
      case 'M':
        return 'Midfielder';
      case 'F':
        return 'Forward';
      default:
        return positionCode;
    }
  }
}
