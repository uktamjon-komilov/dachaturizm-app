import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RatingItem extends StatelessWidget {
  const RatingItem({
    Key? key,
    required this.color,
    required this.percent,
    required this.count,
  }) : super(key: key);

  final Color color;
  final double percent;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: defaultPadding * 3 / 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 70.w,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(
                    width: constraints.maxWidth,
                    height: 14,
                    decoration: BoxDecoration(
                      color: inputGrey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * (percent / 100),
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            "${percent}%",
            style: TextStyles.display8().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyles.display8(),
          ),
        ],
      ),
    );
  }
}
