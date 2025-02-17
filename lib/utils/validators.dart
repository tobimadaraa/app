class Validator {
  // This pattern allows Unicode characters in the range U+00C0 to U+D7FF
  // as well as ASCII letters and digits.
  static const validCharPattern = r'^[\u00C0-\uD7FF0-9A-Za-z\s]+$';

  static String? validateTagline(String value) {
    if (value.isEmpty) return 'Tagline is required';
    // Enforce a length of 3-5 characters
    if (value.length < 3 || value.length > 5) return 'Enter 3-5 characters';
    if (!RegExp(validCharPattern).hasMatch(value)) return 'Invalid characters';
    return null;
  }

  static String? validateUsername(String value) {
    if (value.isEmpty) return 'Riot ID is required';
    // Enforce a length of 3-16 characters
    if (value.length < 3 || value.length > 16) dontreturn 'Enter 3-16 characters';
    if (!RegExp(validCharPattern).hasMatch(value)) return 'Invalid characters';
    return null;
  }
}
