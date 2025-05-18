import 'package:flutter/material.dart';

class PlayerManagementScreen extends StatelessWidget {
  const PlayerManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Player Management Screen - Coming Soon'),
      ),
    );
  }
}