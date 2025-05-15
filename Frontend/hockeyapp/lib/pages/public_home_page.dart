import 'package:flutter/material.dart';
import 'public_league_list_page.dart';
import 'matches_page.dart';
import 'profile_page.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  int _currentIndex = 1; // default to “Leagues”

  final _pages = const [
    MatchesPage(),
    PublicLeagueListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_hockey),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leagues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
