import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});
  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _country = TextEditingController();
  String? _position, _team;

  final _positions = [
    'Forward',
    'Left Wing',
    'Right Wing',
    'Center',
    'Defender',
    'Goalkeeper',
  ];
  final _teams = [
    'Saints Hockey Club',
    'School of Excellence',
    'DTS Hockey Club',
    'Namibia Masters',
    'Wanderers Windhoek',
    'Team X',
    'Coastal Raiders',
    'Sparta Hockey Club',
    'Windhoek Old Boys',
  ];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showPickOptions() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder:
            (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a Photo'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Choose from Gallery'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );
      if (source != null) {
        final picked = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (picked != null) setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _pickDob() async {
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) _dob.text = DateFormat('yyyy-MM-dd').format(picked);
    } catch (e) {
      debugPrint('Date picker error: $e');
    }
  }

  void _submit() {
    try {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Player Info'),
              content: Text(
                'First: ${_firstName.text}\n'
                'Last: ${_lastName.text}\n'
                'DOB: ${_dob.text}\n'
                'Country: ${_country.text}\n'
                'Position: $_position\n'
                'Team: $_team',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      debugPrint('Submission error: $e');
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Enter a Player',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _showPickOptions,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child:
                    _imageFile == null
                        ? const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.white,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showPickOptions,
              child: const Text('+ Image'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _firstName,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastName,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dob,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'DOB',
                border: outline,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _pickDob,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _country,
              decoration: InputDecoration(
                labelText: 'Country',
                border: outline,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _position,
              items:
                  _positions
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
              onChanged: (v) => setState(() => _position = v),
              decoration: InputDecoration(
                labelText: 'Position',
                border: outline,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _team,
              items:
                  _teams
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (v) => setState(() => _team = v),
              decoration: InputDecoration(labelText: 'Team', border: outline),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: const Text('Add Player')),
          ],
        ),
      ),
    );
  }
}
