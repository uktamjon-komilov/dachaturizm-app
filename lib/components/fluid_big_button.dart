import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../constants.dart';

class FluidBigButton extends StatelessWidget {
  const FluidBigButton(
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
          color: Colors.white,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          height: 1.28,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: normalOrange,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: Size(double.infinity, 48),
      ),
    );
  }
}
