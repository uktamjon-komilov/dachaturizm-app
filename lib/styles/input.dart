import 'package:dachaturizm/constants.dart';
import "package:flutter/material.dart";

class InputStyles {
  static OutlineInputBorder inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    );
  }

  static OutlineInputBorder enabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: inputGrey,
        width: 1,
      ),
    );
  }

  static OutlineInputBorder focusBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: normalOrange,
        width: 1,
      ),
    );
  }
}
