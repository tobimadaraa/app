class Validator {
  static const _taglineRegex = r'^[a-zA-Z0-9]{1,6}$';
  static const _usernameRegex = r'^[a-zA-Z0-9]{1,16}$';
  static const _pureNumbersRegex = r'^[0-9]+$';

  static String? validateTagline(String value) {
    if (value.isEmpty) return 'Tagline is required';
    if (value.length < 3 || value.length > 5) return 'Enter 3-5 Characters';
    //  if (RegExp(_pureNumbersRegex).hasMatch(value)) return 'No pure numbers';
    if (!RegExp(_taglineRegex).hasMatch(value)) return 'Invalid characters';
    return null;
  }

  static String? validateUsername(String value) {
    if (value.isEmpty) return 'Riot ID is required';
    if (value.length < 3 || value.length > 16) return 'Enter 3-16 Characters';
    //   if (RegExp(_pureNumbersRegex).hasMatch(value)) return 'No pure numbers';
    if (!RegExp(_usernameRegex).hasMatch(value)) return 'Invalid characters';
    return null;
  }
}
