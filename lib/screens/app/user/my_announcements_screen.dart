import 'package:dachaturizm/components/small_grey_text.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/parse_datetime.dart';
import 'package:dachaturizm/models/ads_plan.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gradients/flutter_gradients.dart';

class MyAnnouncements extends StatefulWidget {
  const MyAnnouncements({Key? key}) : super(key: key);

  static String routeName = "/my-announcements";

  @override
  State<MyAnnouncements> createState() => _MyAnnouncementsState();
}

class _MyAnnouncementsState extends State<MyAnnouncements> {
  List<EstateModel> _estates = [];
  List<AdPlan> _plans = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _actions = [];
  String _adPlan = "";

  _showStatusSnackBar(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: value
            ? Text(
                Locales.string(
                  context,
                  "action_success_completed",
                ),
              )
            : Text(
                Locales.string(
                  context,
                  "something_wrong_not_enough_money",
                ),
              ),
      ),
    );
  }

  _showConfirmAlert([Function? callback, String? description]) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            Locales.string(
              context,
              "confirmation",
            ),
          ),
          content: Container(
            height: 80,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        child: Text(
                          description.toString(),
                          style: TextStyle(fontSize: 14),
                        ),
                        visible: description != null,
                      ),
                      SizedBox(height: defaultPadding / 2),
                      Text(
                        Locales.string(
                          context,
                          "are_you_sure",
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  Locales.string(
                    context,
                    "no",
                  ),
                  style: TextStyle(color: darkPurple),
                )),
            ElevatedButton(
              onPressed: () async {
                if (callback != null) {
                  await callback();
                }
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: Text(
                Locales.string(
                  context,
                  "yes",
                ),
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: normalOrange,
                elevation: 0,
              ),
            )
          ],
        );
      },
    );
  }

  void _navigateToEditScreen([String? id]) {}

  void _openAdsPriceList([String? id]) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return Container(
          height: 350,
          child: Column(
            children: [
              ..._plans
                  .map(
                    (plan) => RadioListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan.title),
                          Text(
                            "${plan.price.toString()} " +
                                Locales.string(
                                  context,
                                  "sum",
                                ),
                          ),
                        ],
                      ),
                      value: plan.slug,
                      groupValue: _adPlan,
                      activeColor: normalOrange,
                      onChanged: (value) {
                        setState(() {
                          _adPlan = value as String;
                        });
                      },
                    ),
                  )
                  .toList(),
              SizedBox(height: 10),
              _buildButtonsBox(context, estateId: id)
            ],
          ),
        );
      }),
    );
  }

  Padding _buildButtonsBox(BuildContext context, {estateId}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: normalOrange,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 10),
              minimumSize: Size(42.w, 50),
              side: BorderSide(color: normalOrange, width: 1),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              Locales.string(context, "cancel"),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: normalOrange,
                onPrimary: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size(42.w, 50)),
            child: Text(
              Locales.string(context, "advertise"),
            ),
            onPressed: () {
              if (_adPlan == "") return;
              _showConfirmAlert(() async {
                setState(() {
                  _isLoading = true;
                });
                Provider.of<EstateProvider>(context, listen: false)
                    .advertise(_adPlan, estateId)
                    .then((value) {
                  _showStatusSnackBar(value);
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            },
          ),
        ],
      ),
    );
  }

  void _chooseAction(EstateModel estate, String action) async {
    final chosenAction =
        _actions.firstWhere((_action) => _action["key"] == action);
    callWithAuth(context, () {
      chosenAction["callback"](estate.id.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<EstateProvider>(context, listen: false)
          .getMyEstates()
          .then((value) {
        setState(() {
          _estates = value;
        });
        Provider.of<CurrencyProvider>(context, listen: false)
            .fetchAdPlans()
            .then((value) {
          setState(() {
            _plans = value;
            _isLoading = false;
          });
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    _actions = [
      {
        "key": "edit",
        "value": Locales.string(context, "edit"),
        "callback": ([String? id]) {
          _navigateToEditScreen(id);
        },
        "hot": false,
      },
      {
        "key": "advertise",
        "value": Locales.string(context, "advertise"),
        "callback": ([String? id]) {
          _openAdsPriceList(id);
        },
        "hot": true,
      },
    ];
    super.didChangeDependencies();
  }

  Widget _buildDateAndViews(EstateModel estate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: normalGrey,
            ),
            SizedBox(width: 5),
            SmallGreyText(
              text: Locales.string(context, "placed") +
                  " " +
                  parseDateTime(
                    estate.created as DateTime,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.remove_red_eye,
              size: 15,
              color: normalGrey,
            ),
            SizedBox(width: 5),
            SmallGreyText(
              text: "${Locales.string(context, "views")} ${estate.views}",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocation(EstateModel estate) {
    return Row(
      children: [
        Icon(
          Icons.location_city,
          size: 15,
          color: normalGrey,
        ),
        SizedBox(width: 5),
        SmallGreyText(text: estate.address),
      ],
    );
  }

  Widget _buildTitleWithStars(EstateModel estate) {
    return Padding(
      padding: const EdgeInsets.only(
        right: defaultPadding * 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            estate.title,
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          SizedBox(height: 5),
          RatingBar.builder(
            ignoreGestures: true,
            initialRating: estate.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 15,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {},
          ),
        ],
      ),
    );
  }

  Widget _buildImageBox(EstateModel estate) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80,
        height: 80,
        child: Image.network(
          estate.photo,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildThreeDots(EstateModel estate) {
    return Positioned(
      right: -15,
      top: -15,
      child: PopupMenuButton<String>(
        elevation: 1,
        onSelected: (String value) {
          _chooseAction(estate, value);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          ..._actions
              .map(
                (action) => PopupMenuItem<String>(
                  value: action["key"],
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 70),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              action["value"].toString(),
                              maxLines: 1,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Visibility(
                            visible: action["hot"],
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: FlutterGradients.happyMemories(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Hot",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Locales.string(
              context,
              "my_announcements",
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    ..._estates
                        .map(
                          (estate) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  EstateDetailScreen.routeName,
                                  arguments: {
                                    "id": estate.id,
                                    "typeId": estate.typeId
                                  });
                            },
                            child: Card(
                              shadowColor: Colors.transparent,
                              color: Colors.white,
                              child: Container(
                                width: 100.w,
                                height: 100,
                                padding: EdgeInsets.all(defaultPadding / 2),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        _buildImageBox(estate),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildTitleWithStars(estate),
                                              _buildLocation(estate),
                                              _buildDateAndViews(estate),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildThreeDots(estate),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
      ),
    );
  }
}
