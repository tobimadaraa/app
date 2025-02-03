import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/buttons/activity_button.dart';
import 'package:flutter_application_2/pages/buttons/logout_button.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/pages/buttons/double_button.dart';
import 'package:flutter_application_2/pages/buttons/my_button.dart';
import 'package:flutter_application_2/pages/buttons/single_button.dart';
import 'package:flutter_application_2/pages/buttons/small_button.dart';
import 'package:flutter_application_2/pages/buttons/date_joined_button.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColours.headerColor,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      color: CustomColours.headerColor,
                      child: Row(mainAxisAlignment: MainAxisAlignment.start),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      color: CustomColours.darkerBackGroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [SizedBox(width: 80, height: 80)],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: ClipOval(
                      child: Image(
                        image: NetworkImage(
                          'https://yt3.googleusercontent.com/Lep5zj2y6yjTwNn9HRP1rtC7_NoCBS6sO8BhwyHmQS59PjdUeMPKS0QZ8N_dj4T2sUXtkEIR=s160-c-k-c0x00ffffff-no-rj',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Container(
              height: 900,
              width: double.infinity,
              color: CustomColours.darkerBackGroundColor,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'un',
                          style: CustomTextStyle.nameOfTextStyle,
                          textAlign: TextAlign.start,
                          textDirection: TextDirection.ltr,
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Not_Un ',
                          textAlign: TextAlign.start,
                          textDirection: TextDirection.ltr,
                          style: CustomTextStyle.nameOfTextStyle.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Mysmallbutton(
                          prefixIcon: Icon(
                            Icons.ac_unit,
                            size: 20,
                            color: Colors.purple,
                          ),
                          mainIcon: Icon(Icons.diamond),
                          trailingIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // ignore: avoid_print
                            print('boop');
                          },
                        ),
                      ],
                    ),

                    Mybutton(
                      prefixIcon: Icon(Icons.edit, color: Colors.white),
                      text: 'Edit Profile',
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                      //  height: 40,
                      //  width: 60,
                    ),
                    SizedBox(height: 16),
                    Activitybutton(
                      abovetext: ('Playing'),
                      prefixIcon: Icon(
                        Icons.help_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                      text: 'Code',
                      text2: '45:42:08',
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                      // height: 80,
                      // width: 120,
                    ),
                    Datejoinedbutton(
                      prefixIcon: Icon(Icons.headset, color: Colors.white),
                      toptext: 'Member Since',
                      text: '10 Jul 2018',
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                    ),
                    Doublebutton(
                      textColor: Colors.purple,
                      prefixIcon: Icon(
                        Icons.ac_unit,
                        size: 20,
                        color: Colors.purple,
                      ),
                      text: 'Get Nitro',
                      trailingIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                    ),
                    Doublebutton(
                      textColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 20,
                      ),
                      text: 'Browse Shop',
                      trailingIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                    ),
                    SizedBox(height: 12),
                    Singlebutton(
                      text: 'Your Friends',
                      trailingIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                    ),
                    SizedBox(height: 6),
                    Singlebutton(
                      text: 'Notes',
                      trailingIcon: Icon(
                        Icons.description,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ignore: avoid_print
                        print('boop');
                      },
                    ),
                    SizedBox(height: 3),
                    Logoutbutton(
                      text: 'Log Out',
                      onPressed: () {
                        // ignore: avoid_print
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
