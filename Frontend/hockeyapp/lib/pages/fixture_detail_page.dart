// fixture_detail_page.dart
import 'package:flutter/material.dart';
import '../services/match_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hockeyapp/config.dart';

class FixtureDetailPage extends StatefulWidget {
  final int fixtureId;
  const FixtureDetailPage({Key? key, required this.fixtureId}) : super(key: key);

  @override
  _FixtureDetailPageState createState() => _FixtureDetailPageState();
}

class _FixtureDetailPageState extends State<FixtureDetailPage> {
  final _homeCtrl = TextEditingController();
  final _awayCtrl = TextEditingController();
  final _minuteCtrl = TextEditingController();
  String _status = 'LIVE';
  final _storage = const FlutterSecureStorage();
  bool _loading = false;

  String? selectedCategory;
  String? selectedEvent;

  int? _selectedScorerId;
  int? _selectedAssistantId;
  int? _injuredPlayerId;
  int? _cardedPlayerId;
  int? _playerInId;
  int? _playerOutId;
  String? _selectedCardType;
  int? _selectedTeamId;

  final List<String> categories = [
    'Scoring',
    'Penalties',
    'Game Flow',
  ];

  final Map<String, List<String>> eventOptions = {
    'Scoring': ['Goal'],
    'Penalties': ['Card'],
    'Game Flow': ['Substitution', 'Injury'],
  };

  @override
  void initState() {
    super.initState();
    _loadFixtureData();
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  Future<Dio> _createAuthDio() async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await _storage.read(key: 'accessToken');
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }

  List<Map<String, dynamic>> _homePlayers = [];
  List<Map<String, dynamic>> _awayPlayers = [];
  Map<String, dynamic>? _fixture;

  Future<void> _loadFixtureData() async {
    setState(() => _loading = true);
    try {
      final dio = await _createAuthDio();
      final resp = await dio.get('/admin/fixtures/${widget.fixtureId}/');
      _fixture = resp.data;

      _homeCtrl.text = _fixture!['home_team_score']?.toString() ?? '';
      _awayCtrl.text = _fixture!['away_team_score']?.toString() ?? '';
      _status = _fixture!['status'] ?? 'RUNNING';

      final homeTeamId = _fixture!['home_team']['id'];
      final awayTeamId = _fixture!['away_team']['id'];

      final playerResp1 = await dio.get('/admin/players/', queryParameters: {'team_id': homeTeamId});
      final playerResp2 = await dio.get('/admin/players/', queryParameters: {'team_id': awayTeamId});

      _homePlayers = List<Map<String, dynamic>>.from(playerResp1.data);
      _awayPlayers = List<Map<String, dynamic>>.from(playerResp2.data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load fixture or players: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitMatchEvent() async {
    final minuteStr = _minuteCtrl.text.trim();
final minute = int.tryParse(minuteStr);

if (minute == null || minute < 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please enter a valid positive minute')),
  );
  return;
}

    final dio = await _createAuthDio();
    final data = {
      'fixture': widget.fixtureId,
      'event_type': selectedEvent?.toLowerCase(),
      'minute': int.tryParse(_minuteCtrl.text) ?? 0, 
    };

    if (selectedEvent == 'Goal') {
      data['player'] = _selectedScorerId;
      if (_selectedAssistantId != null) data['assisting'] = _selectedAssistantId;
    } else if (selectedEvent == 'Card') {
      if (_selectedCardType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a card type')),
        );
        return;
      }
      data['player'] = _cardedPlayerId;
      data['card_type'] = _selectedCardType;
    } else if (selectedEvent == 'Injury') {
      data['player'] = _injuredPlayerId;
    } else if (selectedEvent == 'Substitution') {
      data['sub_in'] = _playerInId;
      data['sub_out'] = _playerOutId;
      data['player'] = _playerOutId;
    }

    try {
      await dio.post('/admin/matchevents/', data: data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match event added')),
      );
      // Optionally clear inputs or refresh events
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $e')),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await MatchService().updateFixture(
        widget.fixtureId,
        homeScore: int.parse(_homeCtrl.text),
        awayScore: int.parse(_awayCtrl.text),
        status: _status,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fixture updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fixture ${widget.fixtureId}'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Match Event'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildMatchEventTab()
          ],
        ),
      ),
    );
  }

  Widget getEventDetails() {
    switch (selectedCategory) {
      case 'Scoring':
        switch (selectedEvent) {
          case 'Goal':
              
            return Column(children: [
              _playerDropdown('Scorer', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _selectedScorerId = val), selectedId: _selectedScorerId),
              _playerDropdown('Assist', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _selectedAssistantId = val), selectedId: _selectedAssistantId),
              TextFormField(
                controller: _minuteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Time (Minute)'),
              ),
              _teamDropdown('Team', (val) => _selectedTeamId = val),
            ]);
        }
        break;
        case 'Penalties':
          return Column(children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Card Type'),
              value: _selectedCardType,
              items: ['green', 'yellow', 'red']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCardType = val),
            ),
            _playerDropdown('Player', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _cardedPlayerId = val), selectedId: _cardedPlayerId),
            _teamDropdown('Team', (val) => _selectedTeamId = val),
            TextFormField(
              controller: _minuteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time (Minute)'),
            )
            ,
          ]);
        case 'Game Flow':
          switch (selectedEvent) {
            case 'Substitution':
              return Column(children: [
                _playerDropdown('Player In', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _playerInId = val), selectedId: _playerInId),
                _playerDropdown('Player Out', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _playerOutId = val), selectedId: _playerOutId),
                _teamDropdown('Team', (val) => _selectedTeamId = val),
                TextFormField(
                  controller: _minuteCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Time (Minute)'),
                )
                ,
              ]);
          case 'Injury':
            return Column(children: [
              _teamDropdown('Team', (val) => _selectedTeamId = val),
              _playerDropdown('Player', [..._homePlayers, ..._awayPlayers], (val) => setState(() => _injuredPlayerId = val), selectedId: _injuredPlayerId),
              TextFormField(
                controller: _minuteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Time (Minute)'),
              )
              ,
            ]);
        }
        break;
    }
    return const SizedBox.shrink();
  }

  Widget _dropdownField(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: options
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: (_) {},
    );
  }

  Widget _teamDropdown(String label, void Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem(value: _fixture?['home_team']['id'], child: Text(_fixture?['home_team']['short_name'] ?? '')),
        DropdownMenuItem(value: _fixture?['away_team']['id'], child: Text(_fixture?['away_team']['short_name'] ?? '')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _playerDropdown(String label, List<Map<String, dynamic>> players, void Function(int?) onChanged, {int? selectedId}) {
    final validValue = players.any((p) => p['id'] == selectedId) ? selectedId : null;

    return DropdownButtonFormField<int>(
      value: validValue,
      decoration: InputDecoration(labelText: label),
      items: players.map<DropdownMenuItem<int>>((p) {
        return DropdownMenuItem<int>(
          value: p['id'] as int,
          child: Text('${p['first_name']} ${p['last_name']}'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }



  Widget _textField(String label) {
    return TextFormField(decoration: InputDecoration(labelText: label));
  }

  Widget _buildGeneralTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Home Score', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _homeCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Away Score', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _awayCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: ['UPCOMING', 'LIVE', 'FINISHED']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchEventTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Category'),
            items: categories
                .map((cat) => DropdownMenuItem(
                    value: cat, child: Text(cat)))
                .toList(),
            value: selectedCategory,
            onChanged: (val) => setState(() {
            selectedCategory = val;
            selectedEvent = null;
            _selectedScorerId = null;
            _selectedAssistantId = null;
            _injuredPlayerId = null;
            _cardedPlayerId = null;
            _playerInId = null;
            _playerOutId = null;
            _selectedCardType = null;
            _selectedTeamId = null;
          }),
          ),
          const SizedBox(height: 16),
          if (selectedCategory != null)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Event'),
              items: eventOptions[selectedCategory]!
                  .map((evt) => DropdownMenuItem(
                      value: evt, child: Text(evt)))
                  .toList(),
              value: selectedEvent,
              onChanged: (val) => setState(() {
                selectedEvent = val;
                _injuredPlayerId = null;
                _playerInId = null;
                _playerOutId = null;
                _selectedScorerId = null;
                _selectedAssistantId = null;
                _cardedPlayerId = null;
                _selectedCardType = null;
                _selectedTeamId = null;
              }),
            ),
          const SizedBox(height: 16),
          if (selectedEvent != null) getEventDetails(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitMatchEvent,
              icon: const Icon(Icons.check),
              label: const Text('Confirm Event'),
            ),
          ),
        ],
      ),
    );
  }


}