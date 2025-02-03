import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String tagline;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.tagline,
  });

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Increment page views when this page is loaded.
    Get.find<UserRepository>().incrementPageViews(
      widget.userId,
      widget.tagline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.userId} Profile')),
      body: Center(child: Text('User Profile Content Here')),
    );
  }
}
