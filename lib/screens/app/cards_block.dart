import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget buildCardsBlock(BuildContext context, List? estates,
    {EdgeInsetsGeometry? padding}) {
  return Visibility(
    visible: estates!.length > 0,
    child: Container(
      width: 100.w,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            defaultPadding,
            0,
            defaultPadding,
            0,
          ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 6,
        children: [
          ...estates.map((estate) => EstateCard(estate: estate)).toList(),
        ],
      ),
    ),
  );
}
