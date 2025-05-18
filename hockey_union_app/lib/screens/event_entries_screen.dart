import 'package:flutter/material.dart';

class EventEntriesScreen extends StatelessWidget {
  const EventEntriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Entries'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Event Entries Screen - Coming Soon'),
      ),
    );
  }
}