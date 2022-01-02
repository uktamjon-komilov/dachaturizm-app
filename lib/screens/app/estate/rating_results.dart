import 'package:dachaturizm/components/rating_item.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_rating_model.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Widget buildRatingResults(
    BuildContext context, EstateRatingModel? estateRating) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Locales.string(context, "rating"),
          style: TextStyles.display7(),
        ),
        SizedBox(height: defaultPadding),
        Row(
          children: [
            Text(
              estateRating!.averageRating.toString(),
              style: TextStyle(
                fontSize: 21,
                height: 1.2,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10),
            RatingBar.builder(
              ignoreGestures: true,
              initialRating: estateRating.averageRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 17,
              itemBuilder: (context, _) => Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
            SizedBox(width: 10),
            Text("${estateRating.total} ${Locales.string(context, 'reviews')}"),
          ],
        ),
        SizedBox(height: defaultPadding / 2),
        ...estateRating.ratings.keys.map((key) {
          RatingModel rating = estateRating.ratings[key] as RatingModel;
          return RatingItem(
            color: ratingColors[int.parse(key) - 1],
            percent: rating.percent == 0.0 ? 1.0 : rating.percent,
            count: rating.count,
          );
        }).toList()
      ],
    ),
  );
}
