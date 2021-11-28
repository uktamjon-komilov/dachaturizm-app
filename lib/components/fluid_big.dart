import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 3),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: disabled ? null : onPress,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color(0xFFF17C31),
            fixedSize: const Size(double.infinity, defaultPadding * 3),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
