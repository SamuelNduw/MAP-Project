import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/pages/login_page.dart';
import 'league_list_page.dart';
import 'team_list_page.dart';
import '../theme/app_theme.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardTab(),
    // LeagueListPage(),
    // TeamListPage(),
    AdminProfileTab(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.navBarBackgroundColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// Placeholder for Dashboard Overview
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: AppTheme.primaryColor),
              const SizedBox(height: 10),
              Text(title, style: AppTheme.cardTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 1,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('images/logo.png', width: 50, fit: BoxFit.contain),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildTile(context, 'Leagues', Icons.emoji_events, '/admin/leagues'),
            _buildTile(context, 'Teams', Icons.group, '/admin/teams'),
            _buildTile(context, 'Players', Icons.sports_hockey, '/admin/players'),
            // _buildTile(context, 'Managers', Icons.person, '/admin/managers'),
            // _buildTile(context, 'Staff', Icons.badge, '/admin/staff'),
            _buildTile(context, 'Fixtures', Icons.calendar_month, '/admin/fixtures'),
          ],
        )
        )
    );
  }
}

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  String? _email;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _loadEmailFromToken();
  }

  Future<void> _loadEmailFromToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        _email = decoded['email'] as String?;
        _fullName = decoded['full_name'] as String?;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 1,
        title: const Text(
          'Admin Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('images/logo.png', width: 50, fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await _handleLogout(context);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text("Admin", style: AppTheme.titleTextStyle),
                const SizedBox(height: 8),
                Text(
                  _fullName ?? "loading...",
                  style: AppTheme.subtitleTextStyle,
                ),
                Text(
                  _email ?? "loading...",
                  style: AppTheme.subtitleTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}