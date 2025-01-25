import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/classm.dart';

class Singlebutton extends StatelessWidget {
  final String text;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Singlebutton({
    super.key,
    required this.text,
    this.prefixIcon,
    this.trailingIcon,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: CustomColours.backGroundColor,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            if (prefixIcon != null)
              Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                ), // Add spacing between icon and text
                child: prefixIcon,
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                  color: CustomColours.greyDiscordText,
                  fontSize: 16, // Adjust font size as needed
                ),
              ),
            ),
            Expanded(child: Container()),
            if (trailingIcon != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 240.0,
                ), // Space between text and trailing icon
                child: trailingIcon,
              ),
          ],
        ),
      ),
    );
  }
}
