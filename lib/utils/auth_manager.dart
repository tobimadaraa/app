// import 'package:flutter/cupertino.dart';
// import 'package:flutter_application_2/gitit/gitit.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthManager {
//   static final ValueNotifier<String?> authChangeNotifier = ValueNotifier(null);
//   static final SharedPreferences _sharedPreferences = locator.get();

//   static void saveToken(String token) {
//     _sharedPreferences.setString('access_token', token);
//     authChangeNotifier.value = token;
//   }

//   static String readAuth() {
//     return _sharedPreferences.getString('access_token') ?? '';
//   }

//   static void logout() {
//     _sharedPreferences.clear();
//     authChangeNotifier.value = null;
//   }
// }
