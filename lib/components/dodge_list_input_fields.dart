import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/components/input_field.dart';
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
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), // ✅ Outer margin
        padding: const EdgeInsets.all(16), // ✅ Inner padding
        decoration: BoxDecoration(
          color: const Color(0xff1d223c)
              .withOpacity(0.4), // ✅ Background color with opacity
          borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
          border: Border.all(
            color: const Color(0xff323449), // ✅ Border color (adjust as needed)
            width: 1.0, // ✅ Border thickness
          ),
        ),
        child: Form(
          key: _formKey,
          // Validate on each user interaction.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: InputField(
                  labelText: 'Enter Riot ID',
                  hintText: 'e.g. doglover (3-16 characters)',
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
              //  const SizedBox(height: 2),
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
                      backgroundColor: Color(0xff37D5F8),
                      disabledBackgroundColor: Color(0xff525252),
                      foregroundColor: _isFormValid
                          ? Colors.white
                          : Colors.grey.shade400, // ✅ Changes text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(64),
                      ),
                      minimumSize: const Size(0, 43),
                    ),
                    child: const Text(
                      "Add to Dodgelist",
                      style: TextStyle(fontSize: 18, fontFamily: 'Kanit'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }
}
