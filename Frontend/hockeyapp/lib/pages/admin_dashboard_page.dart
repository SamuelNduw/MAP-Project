import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Widget _buildTile(BuildContext context, String title, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Center(child: Text(title, style: const TextStyle(fontSize: 16))),
      ),
    );
  }

  Widget _drawerItem(String text, {IconData? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: trailing != null ? Icon(trailing, color: Colors.white) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Colors.blue; // use your app’s blue
    return Scaffold(
      // RIGHT‐SIDE DRAWER
      endDrawer: Drawer(
        child: Container(
          color: blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset('images/logo.png', width: 120),
                ),
              ),
              _drawerItem('Dashboard', onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/admin');
              }),
              _drawerItem('Leagues', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/leagues');
              }),
              _drawerItem('Teams', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/teams');
              }),
              _drawerItem('Players', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/players');
              }),
              _drawerItem('Managers', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/managers');
              }),
              _drawerItem('Staff', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/staff');
              }),
              _drawerItem('Fixtures', trailing: Icons.chevron_right, onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/fixtures');
              }),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png', width: 80, height: 80, fit: BoxFit.contain),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
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
        ),
      ),
    );
  }
}
