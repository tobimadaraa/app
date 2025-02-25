import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_2/Screens/home_page.dart';
import 'package:flutter_application_2/Screens/initialiser.dart';
import 'package:flutter_application_2/Screens/leaderboard_screen.dart';
import 'package:flutter_application_2/Screens/login_screen.dart';
import 'package:flutter_application_2/Screens/dodge_list_screen.dart';
import 'package:flutter_application_2/components/user_controller.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "apikey.env");

  // Register your controllers/repositories with GetX.
  Get.put(UserRepository());
  Get.put(UserController());

  // Wrap your main app with AppInitializer.
  runApp(AppInitializer(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/homepage',
      getPages: [
        GetPage(name: '/homepage', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/leaderboard', page: () => LeaderBoard()),
        GetPage(name: '/discord', page: () => DodgeList()),
      ],
    );
  }
}
