// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_2/Screens/dodge_list_screen.dart';
import 'package:flutter_application_2/Screens/home_page.dart';
import 'package:flutter_application_2/Screens/leaderboard_screen.dart';
import 'package:flutter_application_2/Screens/login_screen.dart';
//import 'package:flutter_application_2/repository/my_ranked_leaderboard.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "apikey.env");
  //await storeLeaderboardInBatches(); // Fetch and store leaderboard
  Get.put(UserRepository());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // You can still use initialRoute if you want:
      initialRoute: '/homepage',
      // Replace MaterialApp's routes with GetX's getPages:
      getPages: [
        GetPage(name: '/homepage', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/leaderboard', page: () => LeaderBoard()),
        GetPage(name: '/discord', page: () => DodgeList(key: dodgeListKey)),
      ],
    );
  }
}
