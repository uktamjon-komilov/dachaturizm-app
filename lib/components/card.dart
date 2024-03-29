import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/format_price.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/estate/image_zoomer.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:animate_do/animate_do.dart';

class EstateCard extends StatefulWidget {
  const EstateCard({
    Key? key,
    required this.estate,
    this.needShadow = true,
  }) : super(key: key);

  final EstateModel estate;
  final bool needShadow;

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
      decoration: widget.needShadow
          ? BoxDecoration(boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 15,
                color: Colors.black.withOpacity(0.07),
              )
            ])
          : null,
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
              Container(
                width: (100.w - 2.25 * defaultPadding) / 2,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return ImageZoomer();
                            },
                            settings: RouteSettings(
                              arguments: {
                                "photos": [
                                  widget.estate.photo,
                                  ...widget.estate.photos
                                      .map((item) => item.photo)
                                      .toList(),
                                ],
                                "current": widget.estate.photo,
                              },
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        cacheKey: widget.estate.thumbnail,
                        imageUrl: widget.estate.thumbnail,
                        fit: BoxFit.cover,
                        height: 145,
                        placeholder: (context, _) => Image.asset(
                          "assets/images/square-placeholder.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    widget.estate.isTop
                        ? _showTopIndicator()
                        : SizedBox.shrink()
                  ],
                ),
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
                              onRatingUpdate: (rating) {},
                            ),
                            Text(
                              "${formatNumber(widget.estate.weekdayPrice.toInt())} ${widget.estate.priceType}",
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
      child: Flash(
        infinite: true,
        controller: _infiniteAnimation,
        key: Key(widget.estate.id.toString()),
        duration: Duration(milliseconds: 2000),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          decoration: BoxDecoration(
            color: normalOrange,
            borderRadius: BorderRadius.circular(5),
            // gradient: LinearGradient(
            //   begin: Alignment.centerLeft,
            //   end: Alignment.centerRight,
            //   colors: [
            //     Color.fromARGB(255, 255, 251, 32),
            //     Color.fromARGB(255, 243, 117, 33)
            //   ],
            // ),
          ),
          child: const Text(
            "TOP",
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  _infiniteAnimation(AnimationController animationController) {
    animationController.addStatusListener((AnimationStatus status) {
      if (status != AnimationStatus.forward) {
        animationController.repeat();
      }
    });
  }
}
