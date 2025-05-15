import 'package:flutter/material.dart';
import '../services/team_service.dart';
import '../services/league_service.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});
  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  List<League> _leagues = [];
  String? _selectedLeagueId;
  bool _loading = false, _fetching = true;

  @override
  void initState() {
    super.initState();
    LeagueService().listLeagues().then((list) {
      setState(() {
        _leagues = list;
        _fetching = false;
      });
    }).catchError((e) {
      setState(() => _fetching = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load leagues: $e')));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await TeamService().createTeam(
        name: _nameCtrl.text.trim(),
        shortName: _shortCtrl.text.trim(),
        logoUrl: _logoCtrl.text.trim(),
        foundedYear: int.parse(_yearCtrl.text.trim()),
      );
      if (!mounted) return;
      // Navigator.pop(context, true);
      Navigator.pushReplacementNamed(context, '/admin/teams');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Team')),
      body: _fetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(shrinkWrap: true, children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _shortCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Short Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _logoCtrl,
                    decoration: const InputDecoration(labelText: 'Logo URL'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _yearCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Founded Year'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLeagueId,
                    decoration: const InputDecoration(labelText: 'League'),
                    items: _leagues
                        .map((l) => DropdownMenuItem(
                              value: l.id.toString(),
                              child: Text(l.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLeagueId = v),
                    validator: (v) =>
                        v == null ? 'Please select a league' : null,
                  ),
                  const SizedBox(height: 16),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit, child: const Text('Create')),
                ]),
              ),
            ),
    );
  }
}
