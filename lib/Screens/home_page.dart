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
      backgroundColor: const Color(0xff2b3254),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF101122),
        selectedItemColor: const Color(0xFF37D5F8),
        unselectedItemColor: Colors.white.withOpacity(0.8),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard, size: 30),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_off, size: 30),
            label: "Dodge List",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
      ),
    );
  }
}
