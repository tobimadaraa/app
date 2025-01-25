import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/classm.dart';

class Activitybutton extends StatelessWidget {
  final String text;
  final String text2;
  final String abovetext;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Activitybutton({
    super.key,
    required this.text,
    required this.text2,
    required this.abovetext,
    this.prefixIcon,
    this.trailingIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: CustomColours.backGroundColor,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10),
        leading: Column(
          children: [
            if (prefixIcon != null)
              Text(
                abovetext,
                style: TextStyle(color: CustomColours.activityButtonColor),
              ),
            prefixIcon!,
          ],
          // child: prefixIcon
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: CustomColours.whiteDiscordText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              text2,
              style: TextStyle(
                color: CustomColours.greenActivityColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: SizedBox(width: 24, child: trailingIcon),
        // minTileHeight: 80,
        minLeadingWidth: 0,
      ),
    );
  }
}
