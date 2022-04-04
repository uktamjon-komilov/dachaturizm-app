import 'package:dachaturizm/constants.dart';
import "package:flutter/material.dart";

class Chips extends StatelessWidget {
  const Chips(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      decoration: BoxDecoration(
          border: Border.all(
            color: darkPurple,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: Text(title),
    );
  }
}
