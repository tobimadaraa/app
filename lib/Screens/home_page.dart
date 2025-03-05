import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For optional SystemChrome tweak
import 'package:flutter_application_2/Screens/dodge_list_screen.dart';
import 'package:flutter_application_2/Screens/leaderboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    LeaderBoard(),
    DodgeList(key: dodgeListKey),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Optional: color the system navigation bar (gesture area) to match
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF101122),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If you want a different page background, set it here
      backgroundColor: Color(0xff2b3254),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Material(
        // 1) Define the shape with rounded top corners
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        // 2) Make sure we actually clip the corners
        clipBehavior: Clip.antiAlias,
        // 3) Color for the bar
        color: const Color(0xFF101122),
        child: BottomNavigationBar(
          // 4) Transparent background so Material color shows through
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF37D5F8),
          unselectedItemColor: Colors.white.withOpacity(0.8),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard, size: 30),
              label: "Leaderboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.block, size: 30),
              label: "Dodge List",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
        ),
      ),
    );
  }
}
