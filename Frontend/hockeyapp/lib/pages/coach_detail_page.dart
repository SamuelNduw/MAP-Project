import 'package:flutter/material.dart';
import 'package:hockeyapp/theme/app_theme.dart';
import '../services/coach_service.dart';

class CoachDetailPage extends StatefulWidget {
  final int id;
  const CoachDetailPage({super.key, required this.id});

  @override
  State<CoachDetailPage> createState() => _CoachDetailPageState();
}

class _CoachDetailPageState extends State<CoachDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final coach = await CoachService().getCoach(widget.id);
      _firstNameCtrl.text = coach.firstName;
      _lastNameCtrl.text = coach.lastName;
      _phoneCtrl.text = coach.phone;
      _emailCtrl.text = coach.email ?? '';
      _photoCtrl.text = coach.photo ?? '';
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load coach: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updatedCoach = await CoachService().updateCoach(
        widget.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        photo: _photoCtrl.text
      );
      Navigator.pop(context, updatedCoach);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update coach: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Coach Details', style: TextStyle(color: Colors.white)),
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
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        controller: _photoCtrl, 
                        decoration: const InputDecoration(labelText: 'Photo URL')
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const CircularProgressIndicator()
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
      );
}
