import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        title: Text('Profile'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('images/logo.png', width: 80, height: 80, fit: BoxFit.contain),  
        )
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          onPressed: () => _handleLogout(context),
        )
      ),
    );
  }
}
