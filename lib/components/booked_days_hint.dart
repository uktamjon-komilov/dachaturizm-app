import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class BookedDaysHint extends StatelessWidget {
  const BookedDaysHint({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: normalOrange,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(width: 10),
        Text(
          Locales.string(context, "booked_days"),
          style: TextStyles.display10(),
        ),
      ],
    );
  }
}
