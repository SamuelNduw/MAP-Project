import 'package:flutter/material.dart';
import 'package:hockeyapp/pages/public_player_detail_page.dart';
import 'package:hockeyapp/services/player_service.dart';

class PublicPlayerListPage extends StatefulWidget {
  const PublicPlayerListPage({super.key});

  @override
  State<PublicPlayerListPage> createState() => _PublicPlayerListPageState();
}

class _PublicPlayerListPageState extends State<PublicPlayerListPage> {
  List<Player> _players = [];
  List<Player> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final list = await PlayerService().publicListPlayers();
      setState(() {
        _players = list;
        _filtered = list;
      });
    } catch (e) {
      print('Error loading players: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _players
        .where((p) => 
          '${p.firstName} ${p.lastName}'.toLowerCase().contains(q) ||
          (p.teamShortName?.toLowerCase().contains(q) ?? false) ||
          (p.position?.toLowerCase().contains(q) ?? false))
      .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search players...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('No players found'))
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final player = _filtered[i];
                            return _PlayerCard(player: player);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicPlayerDetailPage(id: player.id),
            ),
          );
        },
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
                    Text(
                      '${player.firstName} ${player.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Team: ${player.teamShortName ?? "N/A"}'),
                    Text('Position: ${player.position ?? "N/A"}'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}