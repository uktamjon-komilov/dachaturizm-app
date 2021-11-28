import 'dart:ffi';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class TextLinkButton extends StatelessWidget {
  const TextLinkButton(
    this.text,
    this.onTap, {
    Key? key,
  }) : super(key: key);

  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: darkPurple, width: 2),
          ),
        ),
        child: LocaleText(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
