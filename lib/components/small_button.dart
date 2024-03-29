import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  const SmallButton(
    this.text, {
    Key? key,
    required this.enabled,
    required this.onPressed,
  }) : super(key: key);

  final bool enabled;
  final String text;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: defaultPadding / 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          primary: enabled ? normalOrange : disabledOrange,
          minimumSize: Size(40, 25),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: enabled ? Colors.white : greyishLight,
            fontSize: 12,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
