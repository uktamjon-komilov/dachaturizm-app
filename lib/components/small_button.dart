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
          primary: enabled ? normalOrange : disabledOrange,
          minimumSize: Size(40, 25),
          padding: EdgeInsets.symmetric(horizontal: defaultPadding / 3),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
