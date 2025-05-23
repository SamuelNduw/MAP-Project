import 'package:flutter/material.dart';
import 'package:hockeyapp/services/player_service.dart';
import 'package:hockeyapp/services/team_service.dart';
import '../theme/app_theme.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
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
        jerseyNo:
            _jerseyNoCtrl.text.isNotEmpty
                ? int.tryParse(_jerseyNoCtrl.text)
                : null,
        nationality: _nationalityCtrl.text,
        heightCm:
            _heightCmCtrl.text.isNotEmpty
                ? int.tryParse(_heightCmCtrl.text)
                : null,
        weightKg:
            _weightKgCtrl.text.isNotEmpty
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating player: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
          'Create Player',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'images/logo.png',
              width: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_firstNameCtrl, 'First Name *'),
                _buildTextField(_lastNameCtrl, 'Last Name *'),
                _buildTextField(
                  _dobCtrl,
                  'Date of Birth (YYYY-MM-DD) *',
                  hint: '2000-01-01',
                ),
                _buildTeamDropdown(),
                _buildPositionDropdown(),
                _buildTextField(
                  _jerseyNoCtrl,
                  'Jersey Number (Optional)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(_nationalityCtrl, 'Nationality *'),
                _buildTextField(
                  _heightCmCtrl,
                  'Height (cm) (Optional)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _weightKgCtrl,
                  'Weight (kg) (Optional)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _photoCtrl,
                  'Photo URL (Optional)',
                  hint: 'https://example.com/photo.jpg',
                ),
                const SizedBox(height: 24),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator:
            (v) =>
                label.contains('*') && (v == null || v.isEmpty)
                    ? 'Required'
                    : null,
      ),
    );
  }

  Widget _buildTeamDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Team *',
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child:
              _fetchingTeams
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButton<int>(
                    value: _selectedTeamId,
                    hint: const Text('Select Team'),
                    isExpanded: true,
                    items:
                        _teams.map((team) {
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
    );
  }

  Widget _buildPositionDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
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
