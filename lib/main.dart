import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const NamibiaHockeyApp());

class NamibiaHockeyApp extends StatelessWidget {
  const NamibiaHockeyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Namibia Hockey Union',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const AddPlayerPage(),
    debugShowCheckedModeBanner: false,
  );
}

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});
  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  // Form controllers
  final _firstName = TextEditingController();
  final _lastName  = TextEditingController();
  final _dob       = TextEditingController();
  final _country   = TextEditingController();
  String? _position, _team;

  final _positions = [
    'Forward','Left Wing','Right Wing','Center','Defender','Goalkeeper'
  ];
  final _teams = [
    'Saints Hockey Club','School of Excellence','DTS Hockey Club',
    'Namibia Masters','Wanderers Windhoek','Team X',
    'Coastal Raiders','Sparta Hockey Club','Windhoek Old Boys'
  ];

  // Image picker state
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Show bottom sheet to choose camera or gallery
  Future<void> _showPickOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      ),
    );
    if (source != null) {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  // Date picker
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dob.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Submit handler
  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
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
    final blue = Colors.blue[800]!;
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    );
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: blue,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      // RIGHT‐SIDE DRAWER
      endDrawer: Drawer(
        child: Container(
          color: blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset('assets/logo.png', width: 120),
                ),
              ),
              _drawerItem('Home'),
              _drawerItem('About', trailing: Icons.chevron_right),
              _drawerItem('Get Involved', trailing: Icons.chevron_right),
              _drawerItem('Leagues & Events', trailing: Icons.chevron_right),
              _drawerItem('Our Partners'),
              _drawerItem('National Teams', trailing: Icons.chevron_right),
              _drawerItem('Development'),
              _drawerItem('Contact Us'),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,

        // LOGO ON THE LEFT
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/logo.png', width: 80, height: 80, fit: BoxFit.contain),
        ),

        // MENU BUTTON ON THE RIGHT
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Enter a Player',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // PROFILE AVATAR
            Center(
              child: GestureDetector(
                onTap: _showPickOptions,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: blue,
                  backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.person, size: 64, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: _showPickOptions,
                child: const Text('+ Image'),
              ),
            ),
            const SizedBox(height: 24),

            // FORM FIELDS
            TextField(
              controller: _firstName,
              decoration: InputDecoration(labelText: 'First Name', border: outline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastName,
              decoration: InputDecoration(labelText: 'Last Name', border: outline),
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
              decoration: InputDecoration(labelText: 'Country', border: outline),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _position,
              items: _positions
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _position = v),
              decoration: InputDecoration(labelText: 'Position', border: outline),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _team,
              items: _teams
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _team = v),
              decoration: InputDecoration(labelText: 'Team', border: outline),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: _submit,
                child: const Text('Add Player'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String title, {IconData? trailing}) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
      trailing != null ? Icon(trailing, color: Colors.white) : null,
      onTap: () => Navigator.pop(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
