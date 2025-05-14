import 'package:flutter/material.dart';
// import 'screens/home.dart';
// import 'screens/view_player.dart';
// import 'screens/enter_player.dart';
// import 'screens/get_involved_screen.dart';
import 'package:namibia_hockey_union/widgets/nhu_drawer.dart';

void main() => runApp(const NamibiaHockeyApp());

class NamibiaHockeyApp extends StatelessWidget {
  const NamibiaHockeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namibia Hockey Union',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MainScaffold(currentTab: TabItem.home),
        '/add_player':
            (context) => const MainScaffold(currentTab: TabItem.addPlayer),
        '/view_player':
            (context) => const MainScaffold(currentTab: TabItem.viewPlayers),
        '/get_involved':
            (context) => const MainScaffold(currentTab: TabItem.getInvolved),
      },
    );
  }
}
