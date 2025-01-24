import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/classm.dart';

class Mysmallbutton extends StatelessWidget {
  final Icon? prefixIcon;
  final Icon mainIcon;
  final Icon? trailingIcon;
  final void Function() onPressed;
  const Mysmallbutton({
    super.key,
    required this.mainIcon,
    this.prefixIcon,
    this.trailingIcon,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the button horizontally
      children: [
        Card(
          elevation: 0,
          color: CustomColours.backGroundColor,
          child: SizedBox(
            height: 20,
            //    width: 70,
            child: Row(
              children: [
                if (prefixIcon != null) prefixIcon!,
                mainIcon,
                if (trailingIcon != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [trailingIcon!],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
