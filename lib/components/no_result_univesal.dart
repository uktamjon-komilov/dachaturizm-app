import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NoResult extends StatelessWidget {
  const NoResult({
    Key? key,
    required this.photoPath,
    required this.text,
  }) : super(key: key);

  final String photoPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              child: Image.asset(
                photoPath,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              text,
              style: TextStyles.display2().copyWith(
                height: 1.25,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
