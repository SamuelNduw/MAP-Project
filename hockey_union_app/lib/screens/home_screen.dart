import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hockey Union'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Logo or Header
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset(
              'assets/images/logo.png', // You'll need to add this to your assets
              height: 100,
              // If the asset is not available, you might see a placeholder or error
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    'NHU',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Team Registration Button
          _buildNavigationButton(
            context,
            'Enter A Team',
            '/team_registration',
            Icons.group_add,
          ),
          
          const SizedBox(height: 16),
          
          // Event Entries Button
          _buildNavigationButton(
            context,
            'Event Entries',
            '/event_entries',
            Icons.event,
          ),
          
          const SizedBox(height: 16),
          
          // Player Management Button
          _buildNavigationButton(
            context,
            'Player Management',
            '/player_management',
            Icons.person,
          ),
          
          const SizedBox(height: 16),
          
          // Realtime Info Button
          _buildNavigationButton(
            context,
            'Realtime Info',
            '/realtime_info',
            Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, 
    String title, 
    String route, 
    IconData icon,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}