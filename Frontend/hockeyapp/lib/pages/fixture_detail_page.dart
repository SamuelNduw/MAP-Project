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

  List<Map<String, dynamic>> _events = [];
  Map<int, String> _playerNames = {};
  bool _loadingEvents = false;


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
    _loadMatchEvents();
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

      _buildPlayerNamesMap();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load fixture or players: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMatchEvents() async {
    setState(() => _loadingEvents = true);
    try {
      final dio = await _createAuthDio();
      final resp = await dio.get('/admin/matchevents/', queryParameters: {
          'fixture': widget.fixtureId,
      });
      _events = List<Map<String, dynamic>>.from(resp.data);
      _events.sort((a, b) => b['minute'].compareTo(a['minute']));
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    } finally {
      setState(() => _loadingEvents = false);
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

  Future<void> _deleteEvent(int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dio = await _createAuthDio();
      await dio.delete('/admin/matchevents/$eventId/');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted')));
      await _loadMatchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
    }
  }

  Future<void> _updateEvent(int eventId, Map<String, dynamic> updateData) async {
    try {
      final dio = await _createAuthDio();
      await dio.patch('/admin/matchevents/$eventId/', data: updateData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated')));
      await _loadMatchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event: $e')));
    }
  }

  void _buildPlayerNamesMap() {
    final allPlayers = [..._homePlayers, ..._awayPlayers];
    _playerNames = {
      for (var p in allPlayers) p['id'] as int: '${p['first_name']} ${p['last_name']}'
    };
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fixture ${widget.fixtureId}'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Match Event'),
              Tab(text: 'Manage Events')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildMatchEventTab(),
            _buildManageEventsTab()
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

  void _showEditEventDialog(Map<String, dynamic> event) {
    final _minuteEditCtrl = TextEditingController(text: event['minute'].toString());

    String eventType = event['event_type'] ?? '';
    int? playerId = event['player'];
    int? assistingId = event['assisting'];
    String? cardType = event['card_type'];
    int? subInId = event['sub_in'];
    int? subOutId = event['sub_out'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // For player dropdown items, combine _homePlayers and _awayPlayers
            final allPlayers = [..._homePlayers, ..._awayPlayers];

            DropdownMenuItem<int?> buildPlayerDropdownItem(int? val) {
              Map<String, dynamic>? player = allPlayers.cast<Map<String, dynamic>?>().firstWhere(
                (p) => p != null && p['id'] == val,
                orElse: () => null,
              );
              final text = player != null
                  ? '${player['first_name']} ${player['last_name']}'
                  : 'None';
              return DropdownMenuItem(value: val, child: Text(text));
            }

            return AlertDialog(
              title: Text('Edit Event ID: ${event['id']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minute input
                    TextFormField(
                      controller: _minuteEditCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Minute'),
                    ),
                    const SizedBox(height: 10),

                    // Show event type (disabled, no edit)
                    DropdownButtonFormField<String>(
                      value: eventType,
                      decoration: const InputDecoration(labelText: 'Event Type'),
                      items: ['goal', 'card', 'substitution', 'injury']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: null, // Disabled editing event type to keep complexity low
                    ),
                    const SizedBox(height: 10),

                    // Player dropdown
                    DropdownButtonFormField<int?>(
                      value: playerId,
                      decoration: const InputDecoration(labelText: 'Player'),
                      items: allPlayers.map<DropdownMenuItem<int?>>((p) {
                        return DropdownMenuItem<int?>(
                          value: p['id'] as int,
                          child: Text('${p['first_name']} ${p['last_name']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setStateDialog(() => playerId = val),
                    ),
                    const SizedBox(height: 10),

                    // Conditional fields per event type:

                    if (eventType == 'goal') ...[
                      DropdownButtonFormField<int?>(
                        value: assistingId,
                        decoration: const InputDecoration(labelText: 'Assistant (optional)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...allPlayers.map((p) => DropdownMenuItem<int?>(
                                value: p['id'] as int,
                                child: Text('${p['first_name']} ${p['last_name']}'),
                              )),
                        ],
                        onChanged: (val) => setStateDialog(() => assistingId = val),
                      ),
                    ] else if (eventType == 'card') ...[
                      DropdownButtonFormField<String>(
                        value: cardType,
                        decoration: const InputDecoration(labelText: 'Card Type'),
                        items: ['green', 'yellow', 'red']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type[0].toUpperCase() + type.substring(1)),
                                ))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => cardType = val),
                      ),
                    ] else if (eventType == 'substitution') ...[
                      DropdownButtonFormField<int?>(
                        value: subInId,
                        decoration: const InputDecoration(labelText: 'Player In'),
                        items: allPlayers.map((p) => DropdownMenuItem<int?>(
                              value: p['id'] as int,
                              child: Text('${p['first_name']} ${p['last_name']}'),
                            )).toList(),
                        onChanged: (val) => setStateDialog(() => subInId = val),
                      ),
                      DropdownButtonFormField<int?>(
                        value: subOutId,
                        decoration: const InputDecoration(labelText: 'Player Out'),
                        items: allPlayers.map((p) => DropdownMenuItem<int?>(
                              value: p['id'] as int,
                              child: Text('${p['first_name']} ${p['last_name']}'),
                            )).toList(),
                        onChanged: (val) => setStateDialog(() => subOutId = val),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final minute = int.tryParse(_minuteEditCtrl.text.trim());
                    if (minute == null || minute < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid minute')));
                      return;
                    }
                    if (playerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player is required')));
                      return;
                    }
                    if (eventType == 'card' && (cardType == null || cardType!.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card type is required for card events')));
                      return;
                    }
                    if (eventType == 'substitution' && (subInId == null || subOutId == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Both Player In and Player Out are required for substitution')));
                      return;
                    }

                    // Prepare data payload for update
                    final updateData = {
                      'minute': minute,
                      'player': playerId,
                      'event_type': eventType,
                      'assisting': assistingId,
                      'card_type': cardType,
                      'sub_in': subInId,
                      'sub_out': subOutId,
                      'fixture': widget.fixtureId,
                    };

                    // Remove null values to avoid API errors
                    updateData.removeWhere((key, value) => value == null);

                    Navigator.pop(context); // Close dialog before update
                    await _updateEvent(event['id'], updateData);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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

  Widget _buildManageEventsTab() {
    if (_loadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_events.isEmpty) {
      return const Center(child: Text('No events available'));
    }

    

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final playerName = _playerNames[event['player']] ?? 'Unknown';
        final assistingName = event['assisting'] != null ? _playerNames[event['assisting']] ?? 'Unknown' : '';
        final subInName = event['sub_in'] != null ? _playerNames[event['sub_in']] ?? 'Unknown' : '';
        final subOutName = event['sub_out'] != null ? _playerNames[event['sub_out']] ?? 'Unknown' : '';

        String subtitleText = 'Player: $playerName';
        if (event['event_type'] == 'goal' && assistingName.isNotEmpty) {
          subtitleText += '\nAssist: $assistingName';
        } else if (event['event_type'] == 'substitution') {
          subtitleText += '\nIn: $subInName, Out: $subOutName';
        } else if (event['event_type'] == 'card') {
          subtitleText += '\nCard: ${event['card_type'] ?? ''}';
        }


        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text("${event['event_type']?.toUpperCase() ?? ''} - ${event['minute']}'"),
            subtitle: Text(subtitleText),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditEventDialog(event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteEvent(event['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




}