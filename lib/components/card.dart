import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EstateCard extends StatefulWidget {
  const EstateCard({
    Key? key,
    required this.estate,
  }) : super(key: key);

  final EstateModel estate;

  @override
  State<EstateCard> createState() => _EstateCardState();
}

class _EstateCardState extends State<EstateCard> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLiked = widget.estate.isLiked;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (100.w - 2.25 * defaultPadding) / 2,
      height: 246,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 15,
          color: Colors.black.withOpacity(0.07),
        )
      ]),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              EstateDetailScreen.routeName,
              arguments: {
                "id": widget.estate.id,
                "typeId": widget.estate.typeId
              },
            );
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Ink.image(
                    height: 145,
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      widget.estate.photo,
                    ),
                  ),
                  widget.estate.isTop ? _showTopIndicator() : SizedBox.shrink()
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.estate.title,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.33,
                                letterSpacing: 0.1,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                            RatingBar.builder(
                              ignoreGestures: true,
                              initialRating: widget.estate.rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 14,
                              itemBuilder: (context, _) => Icon(
                                Icons.star_rounded,
                                color: yellowish,
                              ),
                              unratedColor: Color(0xFFEDEDED),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            Text(
                              "${widget.estate.weekdayPrice} ${widget.estate.priceType}",
                              style: TextStyles.display4()
                                  .copyWith(color: normalOrange),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            iconSize: 20,
                            onPressed: () async {
                              bool original = _isLiked;
                              await callWithAuth(context, () async {
                                setState(() {
                                  _isLiked = !_isLiked;
                                });
                                Provider.of<EstateProvider>(context,
                                        listen: false)
                                    .toggleWishlist(widget.estate.id, original)
                                    .then((value) {
                                  if (value == null) {
                                    setState(() {
                                      _isLiked = !_isLiked;
                                    });
                                  } else {
                                    setState(() {
                                      _isLiked = value;
                                    });
                                  }
                                });
                              });
                            },
                            icon: Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: favouriteRed,
                              size: 20.0,
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

  Widget _showTopIndicator() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        decoration: BoxDecoration(
            color: normalOrange, borderRadius: BorderRadius.circular(5)),
        child: Text(
          "TOP",
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
