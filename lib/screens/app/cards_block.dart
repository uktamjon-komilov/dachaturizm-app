import 'package:dachaturizm/components/ads_plus_horizontal.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/ads_plus.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget buildCardsBlock(BuildContext context, List<EstateModel>? estates,
    {List<AdsPlusModel>? ads, EdgeInsetsGeometry? padding}) {
  if (ads == null) {
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
    print(ads.length);
    int adIndex = 0;
    List<List<Widget>> items = estates!.map((estate) {
      int index = estates.indexOf(estate);
      if (index != 0 && index % 6 == 0 && adIndex < ads.length) {
        AdsPlusModel ad = ads[adIndex];
        adIndex += 1;
        return [
          AdsPlusHorizontal(ad: ad),
          EstateCard(estate: estate),
        ];
      }
      return [EstateCard(estate: estate)];
    }).toList();

    List<Widget> flattened = [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      flattened.addAll(item);
    }

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
