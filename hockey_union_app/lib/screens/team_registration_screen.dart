import 'package:flutter/material.dart';

class TeamRegistrationScreen extends StatefulWidget {
  const TeamRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form field controllers
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _cellNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _umpireNameController = TextEditingController();
  final TextEditingController _umpireContactController = TextEditingController();
  final TextEditingController _umpireEmailController = TextEditingController();
  final TextEditingController _technicalOfficialController = TextEditingController();
  final TextEditingController _technicalContactController = TextEditingController();
  final TextEditingController _technicalEmailController = TextEditingController();

  // League selection checkboxes
  Map<String, bool> leagueSelections = {
    'Indoor Men Premier': false,
    'Indoor Women Premier': false,
    'Indoor Men Reserve': false,
    'Indoor Women Reserve': false,
    'Indoor Men First': false,
    'Indoor Women First': false,
    'Indoor Men U16': false,
    'Indoor Women U16': false,
    'Outdoor Men Premier': false,
    'Outdoor Women Premier': false,
    'Outdoor Men First': false,
    'Outdoor Women First': false,
    'Outdoor Men U16': false,
    'Outdoor Women U16': false,
  };
  
  bool disclaimerAccepted = false;

  @override
  void dispose() {
    _clubNameController.dispose();
    _contactPersonController.dispose();
    _cellNumberController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _umpireNameController.dispose();
    _umpireContactController.dispose();
    _umpireEmailController.dispose();
    _technicalOfficialController.dispose();
    _technicalContactController.dispose();
    _technicalEmailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check if at least one league is selected
      if (!leagueSelections.values.contains(true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one league')),
        );
        return;
      }

      // Check if disclaimer is accepted
      if (!disclaimerAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the disclaimer')),
        );
        return;
      }

      // Process the form data
      // TODO: Implement API call to submit the form data
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team registration submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter A Team'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Text(
              'Enter A Team',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club Name
                _buildFormField(
                  label: 'Club Name',
                  controller: _clubNameController,
                  required: true,
                ),
                
                // Club Contact Person
                _buildFormField(
                  label: 'Club Contact Person',
                  controller: _contactPersonController,
                  required: true,
                ),
                
                // Contact Person Cell Number
                _buildFormField(
                  label: 'Contact Person Cell Number',
                  controller: _cellNumberController,
                  required: true,
                  keyboardType: TextInputType.phone,
                ),
                
                // Email
                _buildFormField(
                  label: 'Email',
                  controller: _emailController,
                  required: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    // Simple email validation regex
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                // Confirm Email
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Email',
                        controller: _emailController,
                        showLabel: false,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        label: 'Confirm Email',
                        controller: _confirmEmailController,
                        showLabel: false,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != _emailController.text) {
                            return 'Emails do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Confirm Email',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                
                // Nominated Umpire Name
                _buildFormField(
                  label: 'Nominated Umpire Name',
                  controller: _umpireNameController,
                ),
                
                // Nominated Umpire Contact Details
                _buildFormField(
                  label: 'Nominated Umpire Contact Details',
                  controller: _umpireContactController,
                ),
                
                // Nominated Umpire Email
                _buildFormField(
                  label: 'Nominated Umpire Email',
                  controller: _umpireEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                // Nominated Technical Official
                _buildFormField(
                  label: 'Nominated Technical Official',
                  controller: _technicalOfficialController,
                ),
                
                // Nominated Technical Official Contact Details
                _buildFormField(
                  label: 'Nominated Technical Official Contact Details',
                  controller: _technicalContactController,
                ),
                
                // Nominated Technical Official Email
                _buildFormField(
                  label: 'Nominated Technical Official Email',
                  controller: _technicalEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 20),
                
                // League Selection
                const Text(
                  'Please indicate the Leagues your club is interested in participating in *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // League checkboxes
                ...leagueSelections.entries.map(
                  (entry) => CheckboxListTile(
                    title: Text(entry.key),
                    value: entry.value,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      setState(() {
                        leagueSelections[entry.key] = value ?? false;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Disclaimer
                const Text(
                  'Disclaimer *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                CheckboxListTile(
                  title: const Text(
                    'I Understand and will comply with the terms and conditions listed below.',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: disclaimerAccepted,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      disclaimerAccepted = value ?? false;
                    });
                  },
                ),
                
                const Text(
                  'I will ensure that any/all participants from my club have updated and paid '
                  'registrations with the NHU. I understand that no member that is not up to date '
                  'with either their registration nor their payment may participate in and NHU '
                  'event.\n\n'
                  'Registration to the tournament will only be final once I have sent a team '
                  'roster for each one of the team the club entered to the official '
                  'correspondence (secretary@namibiahockey.org) email of the NHU and '
                  'received a response.\n\n'
                  'I understand that my club will be held liable to know and act according to the '
                  'statutes and tournament rules at all times when competing in any NHU '
                  'tournament.',
                  style: TextStyle(fontSize: 12),
                ),
                
                const SizedBox(height: 20),
                
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    bool showLabel = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '$label ${required ? '*' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator ?? (required 
            ? (value) => value == null || value.isEmpty ? 'This field is required' : null
            : null),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}