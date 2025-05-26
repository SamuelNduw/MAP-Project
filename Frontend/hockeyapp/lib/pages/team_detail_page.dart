import 'package:flutter/material.dart';
import 'package:hockeyapp/services/coach_service.dart' as coach_service;
import 'package:hockeyapp/services/team_service.dart';

class TeamDetailPage extends StatefulWidget {
  final int id;
  const TeamDetailPage({super.key, required this.id});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late Future<Team> _teamFuture;
  bool _editing = false;
  
  List<coach_service.Coach> _unassignedCoaches = [];
  coach_service.Coach? _selectedCoach;
  bool _loadingCoaches = false;

  // controllers for editing
  final _nameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _foundedYearCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamFuture = TeamService().getTeam(widget.id);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _logoUrlCtrl.dispose();
    _foundedYearCtrl.dispose();
    super.dispose();
  }

  void _enableEditing(Team team) async {
    setState(() => _editing = true);
    _nameCtrl.text = team.name;
    _shortNameCtrl.text = team.shortName;
    _logoUrlCtrl.text = team.logoUrl;
    _foundedYearCtrl.text = team.foundedYear.toString();

    // Load unassigned coaches (and include currently assigned, if any)
    setState(() => _loadingCoaches = true);
    final coaches = await coach_service.CoachService().listUnassignedCoaches();
    coach_service.Coach? assignedCoach = team.manager; // You'll need to expose this in your Team model
    setState(() {
      _unassignedCoaches = assignedCoach != null
        ? [assignedCoach, ...coaches.where((c) => c.id != assignedCoach.id)]
        : coaches;
      _selectedCoach = assignedCoach;
      _loadingCoaches = false;
    });
  }


  Future<void> _saveChanges() async {
    final data = {
      'name': _nameCtrl.text,
      'short_name': _shortNameCtrl.text,
      'logo_url': _logoUrlCtrl.text,
      'founded_year': int.tryParse(_foundedYearCtrl.text),
      'manager_id': _selectedCoach?.id
    };
    final success = await TeamService().updateTeam(widget.id, data);
    if (success) {
      setState(() {
        _editing = false;
        _teamFuture = TeamService().getTeam(widget.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating team')),
      );
    }
  }

  Future<void> _fetchUnassignedCoaches() async {
    final coaches = await coach_service.CoachService().listUnassignedCoaches();
    setState(() {
      _unassignedCoaches = coaches;
      // Optionally: set _selectedCoach to current coach if already assigned
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
        actions: [
          FutureBuilder<Team>(
            future: _teamFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return IconButton(
                icon: Icon(_editing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_editing) {
                    _saveChanges();
                  } else {
                    _enableEditing(snapshot.data!);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Team>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Team not found'));
          }
          final team = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: _editing ? _buildEditForm() : _buildDetailView(team),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(Team team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.network(team.logoUrl, height: 100),
        ),
        const SizedBox(height: 16),
        Text('Name: ${team.name}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Short Name: ${team.shortName}', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text('Founded Year: ${team.foundedYear}', style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shortNameCtrl,
            decoration: const InputDecoration(labelText: 'Short Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _logoUrlCtrl,
            decoration: const InputDecoration(labelText: 'Logo URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _foundedYearCtrl,
            decoration: const InputDecoration(labelText: 'Founded Year'),
            keyboardType: TextInputType.number,
          ),
          if (_loadingCoaches)
            CircularProgressIndicator()
          else
            DropdownButtonFormField<coach_service.Coach?>(
              value: _selectedCoach,
              items: [
                DropdownMenuItem<coach_service.Coach?>(
                  value: null,
                  child: Text('No Coach'),
                ),
                ..._unassignedCoaches.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.firstName} ${c.lastName}'),
                    ))
              ],
              onChanged: (c) => setState(() => _selectedCoach = c),
              decoration: InputDecoration(labelText: 'Coach'),
            ),
        ],
      ),
    );
  }
}
