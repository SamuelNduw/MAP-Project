import 'package:flutter/material.dart';
import 'package:hockeyapp/services/match_service.dart';
import 'package:hockeyapp/pages/match_detail_page.dart';
import 'package:hockeyapp/theme/app_theme.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  late Future<List<Match>> _fixtures;

  @override
  void initState() {
    super.initState();
    _fixtures = MatchService().listFixtures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Match>>(
        future: _fixtures,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final matches = snap.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (ctx, i) {
              final m = matches[i];
              return InkWell(
                onTap:
                    () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => MatchDetailPage(fixtureId: m.id),
                      ),
                    ),
                child: Card(
                  color: AppTheme.cardColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(m.homeLogo),
                          radius: 20,
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.homeShortName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cardTextStyle,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              m.scoreDisplay,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              m.status,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    m.status == 'FINISHED'
                                        ? Colors.green
                                        : AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Text(
                            m.awayShortName,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cardTextStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundImage: NetworkImage(m.awayLogo),
                          radius: 20,
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
