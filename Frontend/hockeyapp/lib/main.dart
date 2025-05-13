import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/pages/create_team_page.dart';
import 'package:hockeyapp/pages/team_list_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/league_list_page.dart';
import 'pages/create_league_page.dart';
import 'pages/league_detail_page.dart';
// import your other admin pages (teams, players, etc.)

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namibia Hockey Union',
      debugShowCheckedModeBanner: false,

      // Home widget decides initial screen
      home: const AuthGate(),

      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const SignupPage(),
        '/admin': (_) => const AdminDashboardPage(),
        '/admin/leagues': (_) => const LeagueListPage(),
        '/admin/leagues/create': (_) => const CreateLeaguePage(),
        '/admin/teams': (_) => const TeamListPage(),
        '/admin/teams/create': (_) => const CreateTeamPage(),
        // …teams, players, managers, staff, fixtures
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 3 &&
            uri.pathSegments[0] == 'admin' &&
            uri.pathSegments[1] == 'leagues') {
          final id = int.tryParse(uri.pathSegments[2]);
          if (id != null) {
            return MaterialPageRoute(
              builder: (_) => LeagueDetailPage(id: id),
            );
          }
        }
        return null;
      },
    );
  }
}

/// Checks stored token and directs user accordingly.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _storage = const FlutterSecureStorage();
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null && !JwtDecoder.isExpired(token)) {
      setState(() => _isAuthenticated = true);
    } else {
      // remove stale token
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      setState(() => _isAuthenticated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // still checking
    if (_isAuthenticated == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // decide where to go
    return _isAuthenticated!
      ? const AdminDashboardPage()
      : const LoginPage();
  }
}
