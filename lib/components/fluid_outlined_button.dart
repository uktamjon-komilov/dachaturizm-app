import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class FluidOutlinedButton extends StatelessWidget {
  const FluidOutlinedButton(
    this.text, {
    required this.onPress,
    Key? key,
    this.disabled = false,
  }) : super(key: key);

  final String text;
  final VoidCallback onPress;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPress,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: normalOrange,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.28,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        onPrimary: normalOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: normalOrange,
            width: 1,
          ),
        ),
        minimumSize: Size(double.infinity, 48),
      ),
    );
  }
}
