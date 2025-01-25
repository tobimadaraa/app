import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/colour_classes.dart';

class Logoutbutton extends StatelessWidget {
  final String text;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Logoutbutton({
    super.key,
    required this.text,
    this.prefixIcon,
    this.trailingIcon,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
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
                    color: CustomColours.logoutButtonColour,
                    fontSize: 16, // Adjust font size as needed
                  ),
                ),
              ),
              Expanded(child: Container()),
              if (trailingIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [trailingIcon!],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
