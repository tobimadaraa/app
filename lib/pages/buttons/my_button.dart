import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';

class Mybutton extends StatelessWidget {
  final String text;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Mybutton({
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

      color: CustomColours.bluebuttonBackGroundColor,
      child: SizedBox(
        height: 40,
        // width: double.infinity,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers content horizontally
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centers content vertically
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
                color: CustomColours.whiteDiscordText,
                fontSize: 16, // Adjust font size as needed
              ),
            ),
            if (trailingIcon != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                ), // Space between text and trailing icon
                child: trailingIcon,
              ),
          ],
        ),
      ),
    );
  }
}
