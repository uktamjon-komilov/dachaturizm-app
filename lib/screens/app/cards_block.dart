import 'package:dachaturizm/components/ads_plus_horizontal.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/ads_plus.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget buildCardsBlock(
  BuildContext context,
  List<EstateModel>? estates, {
  List<AdsPlusModel>? ads,
  EdgeInsetsGeometry? padding,
  bool isTop = false,
}) {
  if (ads == null || isTop) {
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
  } else {
    int _divider = 6;
    if (estates!.length < 6) {
      _divider = estates.length;
    }
    int adIndex = 0;
    List<List<Widget>> items = estates.map((estate) {
      int index = estates.indexOf(estate);
      if (index != 0 && ((index + 1) % _divider) == 0 && adIndex < ads.length) {
        AdsPlusModel ad = ads[adIndex];
        adIndex += 1;
        return [
          EstateCard(estate: estate),
          AdsPlusHorizontal(ad: ad),
        ];
      }
      return [EstateCard(estate: estate)];
    }).toList();

    print(items);

    List<Widget> flattened = [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      flattened.addAll(item);
    }

    print(ads);

    return Visibility(
      visible: estates.length > 0,
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
          children: flattened,
        ),
      ),
    );
  }
}
