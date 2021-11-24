import 'dart:async';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/detail_builders.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class EstateDetailScreen extends StatefulWidget {
  const EstateDetailScreen({Key? key}) : super(key: key);

  static String routeName = "/estate-detail";

  @override
  State<EstateDetailScreen> createState() => _EstateDetailScreenState();
}

class _EstateDetailScreenState extends State<EstateDetailScreen> {
  var isLoading = true;
  var _showCalendar = true;
  var detail;
  var _detailBuilder;

  void showCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: darkPurple,
      ),
      title: Text(
        "Tavsif",
        style: TextStyle(color: darkPurple),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.send_rounded,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.favorite_border_rounded,
          ),
        ),
      ],
    );
  }

  TableCalendar<dynamic> _buildCustomCalendar() {
    DateTime now = DateTime.now();
    DateTime _selectedDay = DateTime.now();
    DateTime _focusedDay = DateTime.now();

    return TableCalendar(
      firstDay: DateTime.utc(now.year - 1, 1, 1),
      lastDay: DateTime.utc(now.year + 1, 12, 31),
      focusedDay: _selectedDay,
      locale: "uz",
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: darkPurple,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        // titleTextFormatter: (date, locale) =>
        //     "${DateFormat.y(locale).format(date)}, ${DateFormat.MMMM(locale).format(date)}",
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
        return isSameDay(_selectedDay, day);
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
    );
  }

  void didChangeDependencies() {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;
    final int estateId = args["id"];

    Future.delayed(Duration.zero).then((_) =>
        Provider.of<EstateProvider>(context, listen: false)
            .fetchEstateById(args["id"])
            .then((estate) => setState(() {
                  detail = estate;
                  _detailBuilder = DetailBuilder(detail);
                  Future.delayed(Duration(seconds: 1)).then((_) => setState(() {
                        isLoading = false;
                      }));
                })));

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;
    final int estateId = args["id"];

    final halfScreenButtonWidth =
        (MediaQuery.of(context).size.width - 3 * defaultPadding) / 2;

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _detailBuilder.buildSlideShow(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailBuilder.buildTitle(),
                                _detailBuilder.buildRatingRow(),
                                _detailBuilder.buildPriceRow(showCalendar),
                                _detailBuilder.drawDivider(),
                                _showCalendar
                                    ? _buildCustomCalendar()
                                    : SizedBox(),
                                _detailBuilder.drawDivider(),
                                _detailBuilder.buildDescription(),
                                _detailBuilder.buildAddressBox(),
                                _detailBuilder.buildChips(),
                                _detailBuilder.buildAnnouncerBox(),
                                Divider(
                                  color: lightGrey,
                                  thickness: 1,
                                ),
                                Center(
                                  child:
                                      Text("Detail Screen for ID: ${estateId}"),
                                ),
                                SizedBox(
                                  height: 400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _detailBuilder.buildContactBox(halfScreenButtonWidth)
                ],
              ),
      ),
    );
  }
}
