import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // This function prefetches data before your app starts.
  Future<void> _initializeApp() async {
    // Example: Prefetch leaderboard data.
    final userRepository = Get.find<UserRepository>();
    await userRepository.loadFullLeaderboard();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Wrap the loading screen in Directionality to prevent errors.
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    // When initialization is complete, show your main app.
    return widget.child;
  }
}
