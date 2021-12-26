import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

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

  _showLoginScreen() async {
    await Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  Future callWithAuth([Function? callback]) async {
    final access = await Provider.of<AuthProvider>(context, listen: false)
        .getAccessToken();
    if (access != "") {
      if (callback != null) callback();
    } else {
      await _showLoginScreen();
    }
  }

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
      width: (100.w - 2 * defaultPadding) / 2,
      height: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
                arguments: {
                  "id": widget.estate.id,
                  "typeId": widget.estate.typeId
                });
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Ink.image(
                    height: 130,
                    fit: BoxFit.fill,
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
                        padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.estate.title,
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 14,
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
                              "${widget.estate.weekdayPrice.toInt()} ${widget.estate.priceType}",
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                            onPressed: () async {
                              bool original = _isLiked;
                              await callWithAuth(() async {
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
                              color: Colors.red,
                            ),
                          ),
                          // IconButton(
                          //   iconSize: 20,
                          //   onPressed: () async {
                          //     final Set<BookingDay> _selectedDays =
                          //         Set<BookingDay>();
                          //     for (int i = 0;
                          //         i < widget.estate.bookedDays.length;
                          //         i++) {
                          //       _selectedDays.add(widget.estate.bookedDays[i]);
                          //     }
                          //   },
                          //   icon: Icon(
                          //     Icons.calendar_today_outlined,
                          //     color: darkPurple,
                          //   ),
                          // ),
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
