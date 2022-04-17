import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/ads_plus.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AdsPlusHorizontal extends StatelessWidget {
  const AdsPlusHorizontal({
    Key? key,
    this.width,
    required this.ad,
  }) : super(key: key);

  final AdsPlusModel ad;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
            arguments: {"id": ad.id, "typeId": ad.typeId});
      },
      child: Container(
        height: 200,
        width: width == null ? (100.w - 2 * defaultPadding) : width,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.15),
            offset: Offset(0, 4),
            blurRadius: 10,
          )
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: CachedNetworkImage(
              key: Key(ad.photo.toString()),
              cacheKey: ad.photo,
              imageUrl: ad.photo.toString(),
              fit: BoxFit.cover,
              height: 145,
              placeholder: (context, _) => Image.asset(
                "assets/images/square-placeholder.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
