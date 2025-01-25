import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/colour_classes.dart';

class Doublebutton extends StatelessWidget {
  final Color textColor;
  final String text;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Doublebutton({
    super.key,
    required this.textColor,
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
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16, // Adjust font size as needed
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
    );
  }
}
