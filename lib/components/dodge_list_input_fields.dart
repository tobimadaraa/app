import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/components/input_field.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/utils/validators.dart';

class DodgeListInputFields extends StatefulWidget {
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
  // ignore: library_private_types_in_public_api
  _DodgeListInputFieldsState createState() => _DodgeListInputFieldsState();
}

class _DodgeListInputFieldsState extends State<DodgeListInputFields> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  void _validateForm() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _isFormValid = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      // Validate on each user interaction.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: InputField(
              labelText: 'Enter Riot ID',
              hintText: 'e.g. your username',
              onChanged: (value) {
                widget.onUsernameChanged(value);
                _validateForm();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(Validator.validCharPattern),
                ),
              ],
              validator: (value) => Validator.validateUsername(value ?? ''),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: InputField(
              labelText: 'Enter Tagline',
              hintText: 'e.g. NA1',
              onChanged: (value) {
                widget.onTaglineChanged(value);
                _validateForm();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(Validator.validCharPattern),
                ),
              ],
              validator: (value) => Validator.validateTagline(value ?? ''),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid ? widget.onAddUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColours.buttoncolor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  minimumSize: const Size(0, 50),
                ),
                child: const Text("Add to Dodgelist"),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
