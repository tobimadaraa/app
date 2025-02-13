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
        type: BottomNavigationBarType.fixed,
        iconSize: 42,
        backgroundColor: Colors.grey[800],
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 42,
              height: 42,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://yt3.googleusercontent.com/Lep5zj2y6yjTwNn9HRP1rtC7_NoCBS6sO8BhwyHmQS59PjdUeMPKS0QZ8N_dj4T2sUXtkEIR=s160-c-k-c0x00ffffff-no-rj',
                ),
              ),
            ),
            label: 'You',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.square), label: 'dodgelist'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
