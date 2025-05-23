import 'package:flutter/material.dart';
import 'package:hockeyapp/services/player_service.dart';
import 'package:hockeyapp/services/team_service.dart';
import 'package:hockeyapp/theme/app_theme.dart';
// import 'package:hockeyapp/models/player.dart';
// import 'package:hockeyapp/models/team.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update player')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 1,
        title: const Text(
          'Update Player',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildField(_firstNameCtrl, 'First Name'),
                      buildField(_lastNameCtrl, 'Last Name'),
                      buildField(_dobCtrl, 'Date of Birth (YYYY-MM-DD)'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _position,
                          decoration: buildInputDecoration('Position'),
                          items:
                              ['GK', 'D', 'M', 'F']
                                  .map(
                                    (pos) => DropdownMenuItem(
                                      value: pos,
                                      child: Text(pos),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(() => _position = val),
                          validator:
                              (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      buildField(
                        _jerseyNoCtrl,
                        'Jersey Number',
                        keyboardType: TextInputType.number,
                      ),
                      buildField(_nationalityCtrl, 'Nationality'),
                      buildField(
                        _heightCmCtrl,
                        'Height (cm)',
                        keyboardType: TextInputType.number,
                      ),
                      buildField(
                        _weightKgCtrl,
                        'Weight (kg)',
                        keyboardType: TextInputType.number,
                      ),
                      buildField(_photoCtrl, 'Photo URL'),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: DropdownButtonFormField<int>(
                          value: _selectedTeamId,
                          decoration: buildInputDecoration('Team'),
                          items:
                              _teams
                                  .map(
                                    (team) => DropdownMenuItem(
                                      value: team.id,
                                      child: Text(team.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedTeamId = val),
                          validator:
                              (val) => val == null ? 'Select a team' : null,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Update Player',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: buildInputDecoration(label),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
