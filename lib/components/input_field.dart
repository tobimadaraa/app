import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }
}
