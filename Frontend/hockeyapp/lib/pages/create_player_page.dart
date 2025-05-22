import 'package:flutter/material.dart';
import 'package:hockeyapp/services/player_service.dart';
import 'package:hockeyapp/services/team_service.dart';

class CreatePlayerPage extends StatefulWidget {
  const CreatePlayerPage({super.key});

  @override
  State<CreatePlayerPage> createState() => _CreatePlayerPageState();
}

class _CreatePlayerPageState extends State<CreatePlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _jerseyNoCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _heightCmCtrl = TextEditingController();
  final _weightKgCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();

  String? _position;
  int? _selectedTeamId;
  List<Team> _teams = [];
  bool _loading = false;
  bool _fetchingTeams = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await TeamService().listTeams();
      setState(() {
        _teams = teams;
        _fetchingTeams = false;
      });
    } catch (e) {
      setState(() => _fetchingTeams = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load teams: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await PlayerService().createPlayer(
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        dob: _dobCtrl.text,
        position: _position,
        jerseyNo: _jerseyNoCtrl.text.isNotEmpty
            ? int.tryParse(_jerseyNoCtrl.text)
            : null,
        nationality: _nationalityCtrl.text,
        heightCm: _heightCmCtrl.text.isNotEmpty
            ? int.tryParse(_heightCmCtrl.text)
            : null,
        weightKg: _weightKgCtrl.text.isNotEmpty
            ? int.tryParse(_weightKgCtrl.text)
            : null,
        photo: _photoCtrl.text,
        teamId: _selectedTeamId!,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating player: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Player')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'First Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Last Name *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _dobCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD) *',
                    hintText: '2000-01-01',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Team *',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: _fetchingTeams
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButton<int>(
                            value: _selectedTeamId,
                            hint: const Text('Select Team'),
                            isExpanded: true,
                            items: _teams.map((team) {
                              return DropdownMenuItem<int>(
                                value: team.id,
                                child: Text(team.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedTeamId = value);
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _position,
                      hint: const Text('Select Position (Optional)'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'GK', child: Text('Goalkeeper')),
                        DropdownMenuItem(value: 'D', child: Text('Defender')),
                        DropdownMenuItem(value: 'M', child: Text('Midfielder')),
                        DropdownMenuItem(value: 'F', child: Text('Forward')),
                      ],
                      onChanged: (value) {
                        setState(() => _position = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _jerseyNoCtrl,
                  decoration: const InputDecoration(labelText: 'Jersey Number (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nationalityCtrl,
                  decoration: const InputDecoration(labelText: 'Nationality *'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _heightCmCtrl,
                  decoration: const InputDecoration(labelText: 'Height (cm) (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _weightKgCtrl,
                  decoration: const InputDecoration(labelText: 'Weight (kg) (Optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _photoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Photo URL (Optional)',
                    hintText: 'https://example.com/photo.jpg',
                  ),
                ),
                const SizedBox(height: 24),

                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _selectedTeamId == null ? null : _submit,
                        child: const Text('Create Player'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _jerseyNoCtrl.dispose();
    _nationalityCtrl.dispose();
    _heightCmCtrl.dispose();
    _weightKgCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }
}
