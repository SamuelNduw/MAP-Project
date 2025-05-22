import 'package:flutter/material.dart';

class MatchEventForm extends StatefulWidget {
  const MatchEventForm({super.key});

  @override
  State<MatchEventForm> createState() => _MatchEventFormState();
}

class _MatchEventFormState extends State<MatchEventForm> {
  String? selectedCategory;
  String? selectedEvent;

  final List<String> categories = [
    'Scoring',
    'Penalties',
    'Game Flow',
    'Other Events'
  ];

  final Map<String, List<String>> eventOptions = {
    'Scoring': ['Goal', 'Shot on Goal', 'Save'],
    'Penalties': ['Card'],
    'Game Flow': [
      'Start/End Period',
      'Face-off / Push-back',
      'Timeout',
      'Substitution / Line Change',
      'Offside / Icing / Free Hit / Long Corner',
    ],
    'Other Events': ['Injury', 'Video Review'],
  };

  Widget getEventDetails() {
    switch (selectedCategory) {
      case 'Scoring':
        switch (selectedEvent) {
          case 'Goal':
            return Column(children: [
              _textField('Scorer'),
              _textField('Assist'),
              _textField('Time (Minute)'),
              _textField('Team'),
              _dropdownField('Goal Type', [
                'Open play',
                'Penalty stroke',
                'Penalty corner',
                'Power play'
              ]),
            ]);
          case 'Shot on Goal':
            return Column(children: [
              _textField('Shooter'),
              _textField('Time'),
              _dropdownField('Saved or Missed?', ['Saved', 'Missed']),
              _textField('Goalkeeper (if saved)'),
            ]);
          case 'Save':
            return Column(children: [
              _textField('Goalkeeper'),
              _textField('Shooter'),
              _textField('Time'),
              _dropdownField('Shot Type', ['Field shot', 'Penalty corner']),
            ]);
        }
        break;
      case 'Penalties':
        return Column(children: [
          _dropdownField('Card Type', ['Green', 'Yellow', 'Red']),
          _textField('Player'),
          _textField('Team'),
          _textField('Time'),
          _textField('Reason'),
        ]);
      case 'Game Flow':
        switch (selectedEvent) {
          case 'Start/End Period':
            return Column(children: [
              _textField('Period Number'),
              _textField('Time Stamp'),
            ]);
          case 'Face-off / Push-back':
            return Column(children: [
              _textField('Team Starting'),
              _textField('Time'),
            ]);
          case 'Timeout':
            return Column(children: [
              _textField('Team'),
              _textField('Time'),
              _dropdownField(
                  'Type', ['Regular', 'Injury', 'Coach Challenge']),
            ]);
          case 'Substitution / Line Change':
            return Column(children: [
              _textField('Player In'),
              _textField('Player Out'),
              _textField('Team'),
              _textField('Time'),
            ]);
          case 'Offside / Icing / Free Hit / Long Corner':
            return Column(children: [
              _textField('Team'),
              _textField('Time'),
            ]);
        }
        break;
      case 'Other Events':
        switch (selectedEvent) {
          case 'Injury':
            return Column(children: [
              _textField('Player'),
              _textField('Team'),
              _textField('Time'),
              _textField('Nature of Injury (Optional)'),
            ]);
          case 'Video Review':
            return Column(children: [
              _textField('Event Under Review'),
              _dropdownField(
                  'Outcome', ['Confirmed', 'Overturned']),
              _textField('Time'),
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

  Widget _textField(String label) {
    return TextFormField(decoration: InputDecoration(labelText: label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Event Form')),
      body: Padding(
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
                onChanged: (val) => setState(() => selectedEvent = val),
              ),
            const SizedBox(height: 16),
            if (selectedEvent != null) getEventDetails(),
          ],
        ),
      ),
    );
  }
}
