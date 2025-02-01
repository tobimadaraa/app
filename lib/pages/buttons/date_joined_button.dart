import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';

class Datejoinedbutton extends StatelessWidget {
  final String text;
  final String toptext;
  final Icon? prefixIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;

  const Datejoinedbutton({
    super.key,
    required this.text,
    required this.toptext,
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .center, // Align content vertically in the row
            children: [
              if (prefixIcon != null)
                prefixIcon!, // Include the icon directly without padding
              SizedBox(width: 16), // Add spacing between icon and text
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text vertically
                  children: [
                    Text(
                      toptext,
                      style: TextStyle(
                        color: CustomColours.greyDiscordText,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevent overflow
                      maxLines: 5, // Limit lines if needed
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        color: CustomColours.whiteDiscordText,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevent overflow
                      maxLines: 1, // Limit lines if needed
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                trailingIcon!, // Include trailing icon if present
            ],
          ),
        ),
      ),
    );
  }
}
