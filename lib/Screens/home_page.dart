import 'package:flutter/material.dart';
import 'package:flutter_application_2/Screens/user_page.dart';
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
    UserPage(),
    LeaderBoard(),
    DodgeList(key: dodgeListKey),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1B1E30),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: "Leaderboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_off), label: "Dodge List"),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
