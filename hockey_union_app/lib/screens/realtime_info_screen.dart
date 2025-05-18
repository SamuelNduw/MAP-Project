import 'package:flutter/material.dart';

class RealtimeInfoScreen extends StatelessWidget {
  const RealtimeInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Realtime Info Screen - Coming Soon'),
      ),
    );
  }
}