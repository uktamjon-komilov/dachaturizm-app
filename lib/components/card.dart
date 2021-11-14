import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/screens/app/estate_detail_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EstateCard extends StatelessWidget {
  const EstateCard({
    Key? key,
    required this.screenWidth,
    required this.estate,
  }) : super(key: key);

  final int screenWidth;
  final EstateModel estate;

  Widget _showTopIndicator() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.orange, borderRadius: BorderRadius.circular(15)),
        child: Text(
          "TOP",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (screenWidth - 2 * defaultPadding) / 2,
      height: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            print("InkWell tapped!");
            print(estate.id);
            Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
                arguments: {"id": estate.id, "typeId": estate.typeId});
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Ink.image(
                    height: 130,
                    fit: BoxFit.fill,
                    image: NetworkImage(
                      estate.photo,
                    ),
                  ),
                  estate.isTop ? _showTopIndicator() : SizedBox.shrink()
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              estate.title,
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            RatingBar.builder(
                              initialRating: estate.rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20.0,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            Text(
                              "${estate.weekdayPrice.toInt()} ${estate.priceType}",
                              style: TextStyle(
                                  color: darkPurple,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            iconSize: 20,
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite_border_outlined,
                              color: Colors.red,
                            ),
                          ),
                          // SizedBox(
                          //   height: 12,
                          // ),
                          IconButton(
                            iconSize: 20,
                            onPressed: () {},
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              color: darkPurple,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
