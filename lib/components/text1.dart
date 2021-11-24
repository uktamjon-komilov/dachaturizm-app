import 'package:flutter/material.dart';
import 'package:dachaturizm/constants.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Text1 extends StatelessWidget {
  const Text1(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return LocaleText(
      text,
      style: TextStyle(
        color: darkPurple,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
