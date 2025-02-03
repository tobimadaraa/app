import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/input_field.dart';
//import 'package:flutter_application_2/utils/validators.dart';

class DodgeListInputFields extends StatelessWidget {
  final String? usernameError;
  final String? tagLineError;
  final Function(String) onUsernameChanged;
  final Function(String) onTaglineChanged;
  final VoidCallback onAddUser;

  const DodgeListInputFields({
    super.key,
    required this.usernameError,
    required this.tagLineError,
    required this.onUsernameChanged,
    required this.onTaglineChanged,
    required this.onAddUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InputField(
            labelText: 'Enter Riot ID',
            hintText: 'e.g. your username',
            errorText: usernameError,
            onChanged: onUsernameChanged,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InputField(
            labelText: 'Enter Tagline',
            hintText: 'e.g. NA1',
            errorText: tagLineError,
            onChanged: onTaglineChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: onAddUser,
            child: const Text("Add to Dodge List"),
          ),
        ),
      ],
    );
  }
}
