// ignore_for_file: avoid_print

//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Screens/home_page.dart';
import 'package:flutter_application_2/Screens/leaderboard_screen.dart';
import 'package:flutter_application_2/Screens/login_screen.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "apikey.env");
  Get.put(UserRepository());
  //final userRepo = UserRepository.instance;
  // final user = UserModel(userId: "001", tagLine: "Flutter Developer");
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/leaderboard': (context) => LeaderBoard(),
      },
      //home: LoginPage());
    );
  }
}
