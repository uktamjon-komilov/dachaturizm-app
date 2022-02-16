import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import "package:flutter/material.dart";
import 'package:sizer/sizer.dart';

class HorizontalAd extends StatelessWidget {
  const HorizontalAd(
    this.estate, {
    Key? key,
    this.width,
  }) : super(key: key);

  final EstateModel estate;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
            arguments: {"id": estate.id, "typeId": estate.typeId});
      },
      child: Container(
        height: 150,
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: estate.photo,
                  fit: BoxFit.cover,
                  height: 145,
                  placeholder: (context, _) => Image.asset(
                    "assets/images/hap.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    width: 152,
                    height: 150,
                    decoration: BoxDecoration(color: Color(0xCC3B2F43)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estate.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            overflow: TextOverflow.ellipsis,
                            height: 1.25,
                          ),
                          maxLines: 3,
                        ),
                        Text(
                          "${estate.weekdayPrice} ${estate.priceType}",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
