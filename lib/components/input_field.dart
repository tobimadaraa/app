import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import

class InputField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter>? inputFormatters; // Add this
  final FormFieldValidator<String>? validator; // Add this

  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.errorText,
    required this.onChanged,
    this.inputFormatters, // Add this
    this.validator, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Changed from TextField to TextFormField
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
      ),
      onChanged: onChanged,
      inputFormatters: inputFormatters, // Add input formatters
      validator: validator, // Add validator
    );
  }
}
