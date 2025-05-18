import 'package:flutter/material.dart';
import 'package:hockeyapp/services/player_service.dart';

class PublicPlayerDetailPage extends StatefulWidget {
  final int id;

  const PublicPlayerDetailPage({super.key, required this.id});

  @override
  State<PublicPlayerDetailPage> createState() => _PublicPlayerDetailPageState();
}

class _PublicPlayerDetailPageState extends State<PublicPlayerDetailPage> {
  late Future<Player> _playerFuture;

  final Color blue = const Color(0xFF005A8D);
  final double avatarSize = 80.0;

  @override
  void initState() {
    super.initState();
    _playerFuture = PlayerService().getPlayer(widget.id);
  }

  Widget statCard(String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<Player>(
        future: _playerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Player not found'));
          }

          final player = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.firstName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300)),
                            Text(player.lastName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (player.teamShortName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (player.teamLogo != null && player.teamLogo!.isNotEmpty)
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundImage: NetworkImage(player.teamLogo!),
                                        onBackgroundImageError: (_, __) {},
                                      )
                                    else
                                      CircleAvatar(radius: 6, backgroundColor: Colors.grey[400]),
                                    const SizedBox(width: 6),
                                    Text(player.teamShortName!,
                                        style: const TextStyle(
                                            color: Colors.black87, fontSize: 12)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: avatarSize,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(player.photo ?? ''),
                        onBackgroundImageError: (_, __) {},
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoTile(title: player.position ?? 'N/A', subtitle: 'Position'),
                          _InfoTile(title: player.nationality, subtitle: 'Country'),
                          _InfoTile(title: player.dob, subtitle: 'DOB'),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      statCard('Jersey', player.jerseyNo?.toString() ?? 'N/A'),
                      statCard('Height', player.heightCm != null ? '${player.heightCm} cm' : 'N/A'),
                      statCard('Weight', player.weightKg != null ? '${player.weightKg} kg' : 'N/A'),
                      statCard('Team', player.teamShortName ?? 'N/A'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title, subtitle;
  const _InfoTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
