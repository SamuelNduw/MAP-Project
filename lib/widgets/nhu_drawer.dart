import 'package:flutter/material.dart';
import 'package:namibia_hockey_union/screens/view_player.dart';
import 'package:namibia_hockey_union/screens/enter_player.dart';
import 'package:namibia_hockey_union/screens/home.dart';
import 'package:namibia_hockey_union/screens/get_involved_screen.dart';
import 'package:namibia_hockey_union/screens/leagues_events_screen.dart';

enum TabItem { home, addPlayer, viewPlayers, getInvolved, leagues }

class MainScaffold extends StatelessWidget {
  final TabItem currentTab;

  const MainScaffold({super.key, required this.currentTab});

  Widget _buildContent() {
    switch (currentTab) {
      case TabItem.home:
        return const HomeScreen();
      case TabItem.addPlayer:
        return const AddPlayerScreen();
      case TabItem.viewPlayers:
        return const ViewPlayersScreen();
      case TabItem.getInvolved:
        return const GetInvolvedScreen();
      case TabItem.leagues:
        return LeaguesEventsScreen();
    }
  }

  int _currentIndex() {
    switch (currentTab) {
      case TabItem.home:
        return 0;
      case TabItem.addPlayer:
        return 1;
      case TabItem.viewPlayers:
        return 2;
      case TabItem.getInvolved:
        return 3;
      case TabItem.leagues:
        return 4;
    }
  }

  void _onTap(BuildContext context, int index) {
    final routes = [
      TabItem.home,
      TabItem.addPlayer,
      TabItem.viewPlayers,
      TabItem.getInvolved,
      TabItem.leagues,
    ];
    final newTab = routes[index];

    if (newTab != currentTab) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScaffold(currentTab: newTab),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_add_alt),
            selectedIcon: Icon(Icons.person_add),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2),
            label: 'Players',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Involved',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Leagues',
          ),
        ],
      ),
    );
  }
}
