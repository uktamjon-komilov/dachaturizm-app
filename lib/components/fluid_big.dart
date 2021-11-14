import 'package:flutter/material.dart';
import '../constants.dart';

class FluidBigButton extends StatelessWidget {
  const FluidBigButton(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 3),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          child: Text(
            text,
            style: TextStyle(fontSize: 20),
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
