import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_providers.dart';
import "package:flutter/material.dart";
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EstateDetailScreen extends StatefulWidget {
  const EstateDetailScreen({Key? key}) : super(key: key);

  static String routeName = "/estate-detail";

  @override
  State<EstateDetailScreen> createState() => _EstateDetailScreenState();
}

class _EstateDetailScreenState extends State<EstateDetailScreen> {
  var isLoading = true;
  var estate;

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

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;
    final int estateId = args["id"];
    EstateModel detail = Provider.of<EstateProvider>(context)
        .getEstate(args["id"], args["typeId"]);

    print(detail);

    final halfScreenButtonWidth =
        (MediaQuery.of(context).size.width - 3 * defaultPadding) / 2;

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: (isLoading && estate != null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSlideShow(detail),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitle(detail),
                                _buildRatingRow(detail),
                                _buildPriceRow(detail),
                                _drawDivider(),
                                Text("Calendar"),
                                _drawDivider(),
                                _buildDescription(detail),
                                _buildAddressBox(detail),
                                _buildChips(detail),
                                Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                ),
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
                  Container(
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
                          onPressed: () {},
                          child: Text("Qo'ng'iroq qilish"),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Wrap _buildChips(EstateModel detail) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...detail.facilities.map((item) => Chips(item.title)).toList(),
      ],
    );
  }

  Container _buildAddressBox(EstateModel detail) {
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

  Column _buildDescription(detail) {
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

  Divider _drawDivider() {
    return Divider(
      color: lightGrey,
      thickness: 1,
    );
  }

  Text _buildPriceRow(detail) {
    return Text(
      "${detail.weekdayPrice} ${detail.priceType}",
      style: TextStyle(
        color: normalOrange,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Padding _buildRatingRow(EstateModel detail) {
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

  Text _buildTitle(EstateModel detail) {
    return Text(
      detail.title,
      style: TextStyle(
          color: darkPurple, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSlideShow(EstateModel estate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ImageSlideshow(
        width: double.infinity,
        height: 300,
        initialPage: 0,
        indicatorColor: normalOrange,
        indicatorBackgroundColor: lightGrey,
        children: [
          Image.network(
            estate.photo,
            fit: BoxFit.cover,
          ),
          ...estate.photos
              .map((item) => Image.network(
                    item.photo,
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
}

class Chips extends StatelessWidget {
  const Chips(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      decoration: BoxDecoration(
          border: Border.all(
            color: darkPurple,
          ),
          borderRadius: BorderRadius.circular(15)),
      child: Text(title),
    );
  }
}
