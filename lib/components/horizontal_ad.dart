import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import "package:flutter/material.dart";

class HorizontalAd extends StatelessWidget {
  const HorizontalAd(
    this.estate, {
    Key? key,
    this.width = null,
  }) : super(key: key);

  final EstateModel estate;
  final width;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    print(estate);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
            arguments: {"id": estate.id, "typeId": estate.typeId});
      },
      child: Container(
        height: 150,
        width: width == null ? (size.width - 2 * defaultPadding) : width,
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  estate.photo,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: 160,
                    height: 150,
                    decoration: BoxDecoration(color: Color(0xCC3B2F43)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estate.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 2,
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
