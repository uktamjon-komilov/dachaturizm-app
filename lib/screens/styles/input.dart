import 'package:dachaturizm/constants.dart';
import "package:flutter/material.dart";

class InputStyles {
  static OutlineInputBorder inputBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFFBABABA),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static OutlineInputBorder focusBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: normalOrange,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
