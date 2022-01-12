import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dachaturizm/components/booked_days_hint.dart';
import 'package:dachaturizm/components/chips.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/fluid_outlined_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/calculate_distance.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:dachaturizm/screens/app/estate/user_estates_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class DetailBuilder {
  final EstateModel detail;

  DetailBuilder(this.detail);

  Widget buildChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...detail.facilities.map((item) => Chips(item.title)).toList(),
        ],
      ),
    );
  }

  Widget buildAddressBox(context) {
    return Visibility(
      visible: (detail.longtitute != 0.0 && detail.latitute != 0.0),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 20),
        height: 100,
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: detail.address.length > 0,
              child: Expanded(
                flex: 2,
                child: Icon(Icons.share_location_rounded, size: 25),
              ),
            ),
            Visibility(
              visible: detail.address.length > 0,
              child: Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.address,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.33,
                        fontWeight: FontWeight.w600,
                        color: darkPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  UrlLauncher.launch(
                      "https://www.google.com/maps/search/?api=1&query=${detail.longtitute},${detail.latitute}");
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      "assets/images/default_map_placeholder.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Column buildDescription(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Locales.string(context, "detail"),
          style: TextStyles.display7(),
        ),
        SizedBox(height: defaultPadding),
        Text(
          detail.description,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Divider drawDivider() {
    return Divider(
      color: lightGrey,
      thickness: 1,
    );
  }

  Widget buildCustomCalendar(context, bool show) {
    final Set<BookingDay> _selectedDays = Set<BookingDay>();
    for (int i = 0; i < detail.bookedDays.length; i++) {
      _selectedDays.add(detail.bookedDays[i]);
    }

    DateTime now = DateTime.now();
    DateTime _focusedDay = DateTime.now();

    return Visibility(
      visible: (show && _selectedDays.length != 0),
      child: Column(
        children: [
          drawDivider(),
          TableCalendar(
            firstDay: now,
            lastDay: DateTime.utc(now.year + 1, 12, 31),
            focusedDay: _focusedDay,
            locale: Locales.currentLocale(context).toString(),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              titleTextFormatter: (date, locale) =>
                  "${DateFormat.y(locale).format(date)}, ${DateFormat.MMMM(locale).format(date)}",
            ),
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.all(3),
              selectedDecoration: BoxDecoration(
                color: normalOrange,
                borderRadius: BorderRadius.circular(5),
              ),
              todayDecoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(5),
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            selectedDayPredicate: (day) {
              return _selectedDays.contains(BookingDay.toObj(day));
              // return true;
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),
          BookedDaysHint(),
        ],
      ),
    );
  }

  Row buildPriceRow(context, callback) {
    final NumberFormat formatter = NumberFormat("#,##0.00", "en_US");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${formatter.format(detail.weekdayPrice)} ${detail.priceType}",
          style: TextStyle(
            color: normalOrange,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        ElevatedButton(
          onPressed: callback,
          child: Text(
            Locales.string(context, "calendar"),
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            primary: normalOrange,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Padding buildRatingRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          RatingBar.builder(
            ignoreGestures: true,
            initialRating: detail.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 14,
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {},
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "${detail.rating} ${Locales.string(context, 'reviews')}",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Text buildTitle() {
    return Text(
      detail.title,
      style: TextStyle(
        color: darkPurple,
        fontSize: 18,
        height: 1.44,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildSlideShow() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ImageSlideshow(
          width: double.infinity,
          height: 300,
          initialPage: 0,
          indicatorColor: normalOrange,
          indicatorBackgroundColor: lightGrey,
          children: [
            CachedNetworkImage(
              imageUrl: detail.photo,
              fit: BoxFit.cover,
              placeholder: (context, _) => Image.asset(
                "assets/images/placeholder.png",
                fit: BoxFit.cover,
              ),
            ),
            ...detail.photos
                .map((item) => CachedNetworkImage(
                      imageUrl: item.photo,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => Image.asset(
                        "assets/images/placeholder.png",
                        fit: BoxFit.cover,
                      ),
                    ))
                .toList()
          ],
          onPageChanged: (value) {
            print('Page changed: $value');
          },
          // autoPlayInterval: 3000,
          isLoop: true,
        ),
      ),
    );
  }

  Widget buildAnnouncerBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(UserEstatesScreen.routeName,
            arguments: {"userId": detail.userId});
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 20),
        height: 70,
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: detail.userPhoto != ""
                    ? Image.network(
                        fixMediaUrl(detail.userPhoto),
                        fit: BoxFit.cover,
                      )
                    : Image.asset("assets/images/user.png"),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  detail.announcer,
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "${detail.userAdsCount} ${Locales.string(context, 'ads_count')}",
                  style: TextStyle(
                    color: darkPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                print("hi");
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: normalGrey,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildContactBox(context, fromChat, userId) {
    return Visibility(
      visible: userId != null && userId != detail.userId,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FluidOutlinedButton(
                child: Text(
                  Locales.string(context, "messaging_with_announcer"),
                  style: TextStyle(
                    fontSize: 12,
                    color: normalOrange,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    height: 1.28,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onPress: () {
                  if (fromChat) {
                    Navigator.of(context).pop();
                  } else {
                    callWithAuth(context, () {
                      Navigator.of(context)
                          .pushNamed(ChatScreen.routeName, arguments: {
                        "estate": detail,
                        "sender": UserModel(
                          id: detail.userId,
                          adsCount: 0,
                          balance: 0,
                          firstName: "",
                          lastName: "",
                          phone: "",
                          photo: "",
                        )
                      });
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: FluidBigButton(
                onPress: () => UrlLauncher.launch("tel://${detail.phone}"),
                child: Text(
                  Locales.string(context, "direct_call"),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    height: 1.28,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
