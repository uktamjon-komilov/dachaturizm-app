import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaturizm/components/chips.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/estate_model.dart';
import "package:flutter/material.dart";
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class DetailBuilder {
  final EstateModel detail;

  DetailBuilder(this.detail);

  Wrap buildChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...detail.facilities.map((item) => Chips(item.title)).toList(),
      ],
    );
  }

  Container buildAddressBox() {
    return Container(
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
          Expanded(
            flex: 2,
            child: Icon(Icons.share_location_rounded, size: 25),
          ),
          Expanded(
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
                      color: darkPurple),
                ),
                Text(
                  "Sizdan 30 km uzoqlikda",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: darkPurple,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.network(
                  "https://www.google.com/maps/d/u/0/thumbnail?mid=1gCp14XBdnEqKjRPIYCzR6MU9oMo&hl=en",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Column buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tavsif",
          style: TextStyle(
              fontSize: 16, color: darkPurple, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          detail.description,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.5,
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

  TableCalendar<dynamic> buildCustomCalendar() {
    final Set<BookingDay> _selectedDays = Set<BookingDay>();
    for (int i = 0; i < detail.bookedDays.length; i++) {
      _selectedDays.add(detail.bookedDays[i]);
      print(_selectedDays);
    }

    DateTime now = DateTime.now();
    DateTime _focusedDay = DateTime.now();

    return TableCalendar(
      firstDay: now,
      lastDay: DateTime.utc(now.year + 1, 12, 31),
      focusedDay: _focusedDay,
      locale: "uz",
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
    );
  }

  Row buildPriceRow(callback) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${detail.weekdayPrice} ${detail.priceType}",
          style: TextStyle(
            color: normalOrange,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        ElevatedButton(
          onPressed: callback,
          child: Text(
            "Kalendar",
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

  Padding buildRatingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          RatingBar.builder(
            initialRating: detail.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 25.0,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
          SizedBox(
            width: 10,
          ),
          Text("${detail.rating} Ovoz")
        ],
      ),
    );
  }

  Text buildTitle() {
    return Text(
      detail.title,
      style: TextStyle(
          color: darkPurple, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget buildSlideShow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
          ),
          ...detail.photos
              .map((item) => CachedNetworkImage(
                    imageUrl: item.photo,
                    fit: BoxFit.cover,
                  ))
              .toList()
        ],
        onPageChanged: (value) {
          print('Page changed: $value');
        },
        autoPlayInterval: 3000,
        isLoop: true,
      ),
    );
  }

  Container buildAnnouncerBox() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 20),
      height: 70,
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            child: ClipOval(
              child: Image.network(
                "https://www.biography.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MTc5ODc1NTM4NjMyOTc2Mzcz/gettyimages-693134468.jpg",
              ),
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
                "Ali Rahmatullayev",
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
                "${detail.userAdsCount}ta e’lon mavjud",
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
    );
  }

  Container buildContactBox(double halfScreenButtonWidth) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                primary: normalOrange,
                backgroundColor: Colors.white,
                side: BorderSide(
                  width: 1,
                  color: normalOrange,
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size(halfScreenButtonWidth, 50),
              ),
              child: Text("Xabar yuborish"),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: normalOrange,
                onPrimary: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size(halfScreenButtonWidth, 50)),
            onPressed: () => UrlLauncher.launch("tel://+998995175347"),
            child: Text("Qo'ng'iroq qilish"),
          )
        ],
      ),
    );
  }
}
