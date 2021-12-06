import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

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
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
