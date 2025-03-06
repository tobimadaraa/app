import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TextStyle? textStyle; // 🟢 New: Style for input text
  final TextStyle? hintTextStyle; // 🟢 New: Style for hint text
  final TextStyle? labelTextStyle; // 🟢 New: Style for label text

  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.errorText,
    required this.onChanged,
    this.inputFormatters,
    this.validator,
    this.textStyle, // 🟢 Allow custom text style
    this.hintTextStyle, // 🟢 Allow custom hint text style
    this.labelTextStyle, // 🟢 Allow custom label text style
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelText: labelText,
        labelStyle: labelTextStyle ??
            const TextStyle(color: Colors.white), // 🟢 Default label color
        hintText: hintText,
        hintStyle: hintTextStyle ??
            const TextStyle(color: Colors.red), // 🟢 Default hint color
        errorText: errorText,
      ),
      style: textStyle ??
          const TextStyle(color: Colors.white), // 🟢 Default input text color
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
