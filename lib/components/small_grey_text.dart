import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';

class SmallGreyText extends StatelessWidget {
  const SmallGreyText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: normalGrey,
        fontSize: 10,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: 1,
    );
  }
}
