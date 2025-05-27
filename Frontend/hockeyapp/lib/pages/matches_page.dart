import 'package:flutter/material.dart';
import 'package:hockeyapp/services/match_service.dart';
import 'package:hockeyapp/pages/match_detail_page.dart';
import 'package:hockeyapp/theme/app_theme.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});
  @override State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> with SingleTickerProviderStateMixin{
  late Future<List<Match>> _fixtures;
  late TabController _tabController;
  final _tabScrollController = ScrollController();

  final int todayTabIndex = 2;

  final List<Map<String, Object>> tabDefs = [
    {'label': '3 days ago', 'offset': -3},
    {'label': '2 days ago', 'offset': -2},
    {'label': 'Yesterday', 'offset': -1},
    {'label': 'Today', 'offset': 0},
    {'label': 'Tomorrow', 'offset': 1},
    {'label': '2 days later', 'offset': 2},
    {'label': '3 days later', 'offset': 3},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabDefs.length, vsync: this, initialIndex: todayTabIndex);

    // Delay to ensure TabBar is built before trying to scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenterSelectedTab();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _scrollToCenterSelectedTab();
      }
    });

    _fixtures = MatchService().listFixtures();
  }

  Future<bool> isAdminUser() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) return false;
    final decoded = JwtDecoder.decode(token);
    return decoded['role'] == 'ADMIN';
  }


  void _scrollToCenterSelectedTab() {
    // Get the width of a tab. This assumes all tabs are the same width. Adjust if needed.
    double tabWidth = 100; // You may want to measure this dynamically for dynamic tab widths.
    double screenWidth = MediaQuery.of(context).size.width;
    double offset = (tabWidth * _tabController.index) - (screenWidth - tabWidth) / 2;

    if (offset < 0) offset = 0;
    _tabScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Map<String, List<Match>> groupMatchesByLeague(List<Match> matches) {
    final Map<String, List<Match>> leagueMap = {};
    for (var m in matches) {
      leagueMap.putIfAbsent(m.leagueName, () => []).add(m);
    }
    return leagueMap;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> tabDefs = [
      {'label': '3 days ago', 'offset': -3},
      {'label': '2 days ago', 'offset': -2},
      {'label': 'Yesterday', 'offset': -1},
      {'label': 'Today', 'offset': 0},
      {'label': 'Tomorrow', 'offset': 1},
      {'label': '2 days later', 'offset': 2},
      {'label': '3 days later', 'offset': 3},
    ];

    final todayTabIndex = 3; // Index for "Today"

    // Utility to group matches by league name
    Map<String, List<Match>> groupMatchesByLeague(List<Match> matches) {
      final Map<String, List<Match>> leagueMap = {};
      for (var m in matches) {
        leagueMap.putIfAbsent(m.leagueName, () => []).add(m);
      }
      return leagueMap;
    }

    return DefaultTabController(
      length: tabDefs.length,
      initialIndex: todayTabIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          leadingWidth: 140,
          leading: FutureBuilder<bool>(
            future: isAdminUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink(); // Placeholder while loading
              }
              if (snapshot.data == true) {
                return Row(
                  children: [
                    const BackButton(color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Image.asset(
                        'images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain
                      )
                    )
                  ]
                ); // Show BackButton if admin
              }
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                        'images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain
                    )
                  )
                ],
              ); // No back button otherwise
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [for (final t in tabDefs) Tab(text: t['label'] as String)],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () async {
                final result = await showSearch(
                  context: context,
                  delegate: MatchSearchDelegate(matches: _fixtures),
                );
                if (result != null) {
                  // Jump to detail page of the selected match
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchDetailPage(fixtureId: result.id),
                    ),
                  );
                }
              },
            ),
          ],
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

            return TabBarView(
              children: tabDefs.map((tab) {
                final offset = tab['offset'] as int;
                final today = DateTime.now();
                final tabDate = DateTime(today.year, today.month, today.day).add(Duration(days: offset));
                final filtered = matches.where((m) {
                  final matchDate = DateTime.parse(m.date);
                  final matchDay = DateTime(matchDate.year, matchDate.month, matchDate.day);
                  return matchDay == tabDate;
                }).toList();

                final grouped = groupMatchesByLeague(filtered);

                if (grouped.isEmpty) {
                  return const Center(child: Text('No matches'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.expand((entry) {
                    final league = entry.key;
                    final leagueMatches = entry.value;
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          league,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 66, 66, 66),
                          ),
                        ),
                      ),
                      ...leagueMatches.map((m) => InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchDetailPage(fixtureId: m.id),
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              CircleAvatar(backgroundImage: NetworkImage(m.homeLogo)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(m.homeShortName, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              Column(children: [
                                Text(m.scoreDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(m.status, style: TextStyle(color: m.status=='FINISHED' ? Colors.green : Colors.orange)),
                              ]),
                              Expanded(child: Text(m.awayShortName, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 8),
                              CircleAvatar(backgroundImage: NetworkImage(m.awayLogo)),
                            ]),
                          ),
                        ),
                      )),
                    ];
                  }).toList(),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

}

class MatchSearchDelegate extends SearchDelegate<Match?> {
  final Future<List<Match>> matches;

  MatchSearchDelegate({required this.matches});

  @override
  String get searchFieldLabel => 'Team or League';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => 
    IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Match>>(
      future: matches,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final lower = query.toLowerCase();
        final filtered = snapshot.data!.where((m) =>
            m.homeName.toLowerCase().contains(lower) ||
            m.awayName.toLowerCase().contains(lower) ||
            m.homeShortName.toLowerCase().contains(lower) ||
            m.awayShortName.toLowerCase().contains(lower) ||
            m.leagueName.toLowerCase().contains(lower)).toList();

        if (filtered.isEmpty) return const Center(child: Text('No matches found'));

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final m = filtered[i];
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(m.homeLogo)),
              title: Text('${m.homeShortName} vs ${m.awayShortName}'),
              subtitle: Text(m.leagueName),
              onTap: () => close(context, m),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

