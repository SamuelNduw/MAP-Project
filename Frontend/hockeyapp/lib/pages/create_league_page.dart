import 'package:flutter/material.dart';
import '../services/league_service.dart';

class CreateLeaguePage extends StatefulWidget {
  const CreateLeaguePage({super.key});
  @override
  State<CreateLeaguePage> createState() => _CreateLeaguePageState();
}

class _CreateLeaguePageState extends State<CreateLeaguePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _season = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  String _status = 'SCHEDULED';
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final league = await LeagueService().createLeague(
        name: _name.text,
        season: _season.text,
        startDate: _start.text,
        endDate: _end.text,
        status: _status,
      );
      if (!context.mounted) return;
      Navigator.pop(context, league);
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create League')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(shrinkWrap: true, children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _season,
              decoration: const InputDecoration(labelText: 'Season'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _start,
              decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _end,
              decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['SCHEDULED','RUNNING','COMPLETED']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create'),
                ),
          ]),
        ),
      ),
    );
  }
}
