import 'dart:ffi';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class TextLinkButton extends StatelessWidget {
  const TextLinkButton(
    this.text,
    this.namedRoute, {
    Key? key,
  }) : super(key: key);

  final String text;
  final String namedRoute;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // namedRoute != ""
        //     ? Navigator.of(context).pushReplacementNamed(namedRoute)
        //     : null;
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(color: darkPurple, width: 3),
        )),
        child: Text(text,
            style: TextStyle(
              color: darkPurple,
              fontSize: 16,
            )),
      ),
    );
  }
}
