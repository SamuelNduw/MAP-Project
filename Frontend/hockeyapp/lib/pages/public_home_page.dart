import 'package:flutter/material.dart';
import 'public_league_list_page.dart';
import 'matches_page.dart';
import 'profile_page.dart';
import 'public_player_list_page.dart';
import 'public_match_events.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({super.key});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  int _currentIndex = 1; // default to “Leagues”

  // final List<Widget> _pages =  [
  //   MatchesPage(),
  //   PublicLeagueListPage(),
  //   PublicPlayerListPage(),
  //   ProfilePage(),
  // ];
  Widget _getCurrentPage() {
  switch (_currentIndex) {
    case 0: return PublicMatchEventsPage();
    case 1: return PublicLeagueListPage();
    case 2: return PublicPlayerListPage();
    case 3: return ProfilePage();
    default: return PublicLeagueListPage();
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _getCurrentPage(),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.sports_hockey), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Leagues'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

}
