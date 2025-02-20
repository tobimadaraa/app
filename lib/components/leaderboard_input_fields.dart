import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/input_field.dart';
//import 'package:flutter_application_2/utils/validators.dart';

class LeaderboardInputFields extends StatelessWidget {
  final String? usernameError;
  final String? taglineError;
  final Function(String) onUsernameChanged;
  final Function(String) onTaglineChanged;

  const LeaderboardInputFields({
    super.key,
    required this.usernameError,
    required this.taglineError,
    required this.onUsernameChanged,
    required this.onTaglineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: InputField(
            labelText: 'Enter Riot ID',
            hintText: 'e.g. your username',
            errorText: usernameError,
            onChanged: onUsernameChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: InputField(
            labelText: 'Enter Tagline',
            hintText: 'e.g. NA1 (max 6 letters/numbers)',
            errorText: taglineError,
            onChanged: onTaglineChanged,
          ),
        ),
      ],
    );
  }
}
