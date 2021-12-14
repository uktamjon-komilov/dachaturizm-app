import 'dart:async';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/detail_builders.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EstateDetailScreen extends StatefulWidget {
  const EstateDetailScreen({Key? key}) : super(key: key);

  static String routeName = "/estate-detail";

  @override
  State<EstateDetailScreen> createState() => _EstateDetailScreenState();
}

class _EstateDetailScreenState extends State<EstateDetailScreen> {
  var isLoading = true;
  var _showCalendar = false;
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

  void didChangeDependencies() {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;

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

    final halfScreenButtonWidth = (100.w - 3 * defaultPadding) / 2;

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
                                    ? _detailBuilder.buildCustomCalendar()
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
