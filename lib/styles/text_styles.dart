import 'package:flutter/material.dart';
import 'package:dachaturizm/constants.dart';

class TextStyles {
  static TextStyle display4() {
    return TextStyle(
      color: darkPurple,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle display3() {
    return TextStyle(
      fontSize: 12,
      letterSpacing: 0.2,
      height: 1.66,
    );
  }

  static TextStyle display2() {
    return TextStyle(
      color: darkPurple,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5625,
    );
  }
}
