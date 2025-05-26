import 'package:flutter/material.dart';
import 'package:hockeyapp/services/player_service.dart';
import 'package:hockeyapp/services/team_service.dart';
import 'package:hockeyapp/theme/app_theme.dart';

class UpdatePlayerPage extends StatefulWidget {
  final Player player;

  const UpdatePlayerPage({super.key, required this.player});

  @override
  State<UpdatePlayerPage> createState() => _UpdatePlayerPageState();
}

class _UpdatePlayerPageState extends State<UpdatePlayerPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _jerseyNoCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _heightCmCtrl;
  late TextEditingController _weightKgCtrl;
  late TextEditingController _photoCtrl;

  String? _position;
  int? _selectedTeamId;
  List<Team> _teams = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _firstNameCtrl = TextEditingController(text: p.firstName);
    _lastNameCtrl = TextEditingController(text: p.lastName);
    _dobCtrl = TextEditingController(text: p.dob.toString());
    _jerseyNoCtrl = TextEditingController(text: p.jerseyNo?.toString() ?? '');
    _nationalityCtrl = TextEditingController(text: p.nationality);
    _heightCmCtrl = TextEditingController(text: p.heightCm?.toString() ?? '');
    _weightKgCtrl = TextEditingController(text: p.weightKg?.toString() ?? '');
    _photoCtrl = TextEditingController(text: p.photo ?? '');
    _position = p.position;
    _selectedTeamId = p.teamId;
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    final list = await TeamService().listTeams();
    setState(() => _teams = list);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'first_name': _firstNameCtrl.text,
      'last_name': _lastNameCtrl.text,
      'dob': _dobCtrl.text,
      'jersey_no': int.tryParse(_jerseyNoCtrl.text),
      'nationality': _nationalityCtrl.text,
      'height_cm': int.tryParse(_heightCmCtrl.text),
      'weight_kg': int.tryParse(_weightKgCtrl.text),
      'photo': _photoCtrl.text,
      'position': _position,
      'team_id': _selectedTeamId,
    };

    setState(() => _loading = true);
    final ok = await PlayerService().updatePlayer(widget.player.id, data);
    setState(() => _loading = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update player')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Update Player', style: TextStyle(color: Colors.white)),
      backgroundColor: AppTheme.primaryColor,
      leadingWidth: 140,
      leading: Row(
        children: [
          const BackButton(color: Colors.white,),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Image.asset(
              'images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            )
          )
        ],
      )
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'First Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Last Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  DropdownButtonFormField(
                    value: _position,
                    decoration: const InputDecoration(labelText: 'Position'),
                    items: ['GK', 'D', 'M', 'F'].map((pos) => DropdownMenuItem(value: pos, child: Text(pos))).toList(),
                    onChanged: (val) => setState(() => _position = val),
                  ),
                  TextFormField(controller: _jerseyNoCtrl, decoration: const InputDecoration(labelText: 'Jersey Number'), keyboardType: TextInputType.number),
                  TextFormField(controller: _nationalityCtrl, decoration: const InputDecoration(labelText: 'Nationality'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _heightCmCtrl, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
                  TextFormField(controller: _weightKgCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
                  TextFormField(controller: _photoCtrl, decoration: const InputDecoration(labelText: 'Photo URL')),
                  DropdownButtonFormField(
                    value: _selectedTeamId,
                    decoration: const InputDecoration(labelText: 'Team'),
                    items: _teams.map((team) => DropdownMenuItem(value: team.id, child: Text(team.name))).toList(),
                    onChanged: (val) => setState(() => _selectedTeamId = val),
                    validator: (val) => val == null ? 'Select a team' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _submit, child: const Text('Update Player')),
                ],
              ),
            ),
          ),
  );
}
