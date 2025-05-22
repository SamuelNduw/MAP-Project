import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/pages/login_page.dart';
// Import any other admin tab pages here

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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// Placeholder for Dashboard Overview
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Widget _buildTile(BuildContext context, String title, String route){
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Center(
            child: Text(title, style: const TextStyle(fontSize: 16)),
          )
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png', width: 80, height: 80, fit: BoxFit.contain),  
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildTile(context, 'Leagues', '/admin/leagues'),
            _buildTile(context, 'Teams', '/admin/teams'),
            _buildTile(context, 'Players', '/admin/players'),
            _buildTile(context, 'Managers', '/admin/managers'),
            _buildTile(context, 'Staff', '/admin/staff'),
            _buildTile(context, 'Fixtures', '/admin/fixtures'),
          ],
        )
        )
    );
  }
}

/// Placeholder for Admin Profile/Settings
class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');

    // Push PublicHomePage and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png', width: 80, height: 80, fit: BoxFit.contain),  
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext dialogContext){
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
              }
            ),
          )
        ],
      ),
      body: Center(
        child: Text('Profile Page')
      ),
    );
  }
}
