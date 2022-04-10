import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/no_result_univesal.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/small_grey_text.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/parse_datetime.dart';
import 'package:dachaturizm/models/ads_plan.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MyAnnouncements extends StatefulWidget {
  const MyAnnouncements({Key? key}) : super(key: key);

  static String routeName = "/my-announcements";

  @override
  State<MyAnnouncements> createState() => _MyAnnouncementsState();
}

class _MyAnnouncementsState extends State<MyAnnouncements> {
  bool _isInit = true;
  List<EstateModel> _allEstates = [];
  List<EstateModel> _simpleEstates = [];
  List<EstateModel> _topEstates = [];
  List<EstateModel> _bannerEstates = [];
  List<EstateModel> _topBannerEstates = [];
  List<EstateModel> _adEstates = [];
  List<EstateModel> _currentEstates = [];
  Map<String, bool> _show = {
    "all": true,
    "simple": false,
    "top": false,
    "banner": false,
    "topbanner": false,
    "ad": false,
  };

  List<AdPlan> _plans = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _actions = [];
  List<String> _adPlans = [];
  double _adsTotal = 0.0;

  void _chooseAction(EstateModel estate, String action) async {
    final chosenAction =
        _actions.firstWhere((_action) => _action["key"] == action);
    callWithAuth(context, () {
      chosenAction["callback"](estate.id.toString());
    });
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
    });

    Future.wait([
      _fetchEstates(),
      Provider.of<AuthProvider>(context, listen: false)
          .getUserDataWithoutNotifying(),
      Provider.of<CurrencyProvider>(context, listen: false)
          .fetchAdPlans()
          .then((value) {
        setState(() {
          _plans = value;
        });
      }),
    ]).then((_) {
      setState(() {
        _isLoading = false;
        _currentEstates = _allEstates;
      });
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .changePageIndex(4);
    });
  }

  Future _fetchEstates([String? term]) async {
    await Provider.of<EstateProvider>(context, listen: false)
        .getMyEstates(term)
        .then((value) {
      _setValues(value);
    });
  }

  _setValues(List<EstateModel> value) {
    setState(() {
      _allEstates = value;
      _simpleEstates = value
          .where(
            (element) => (element.isSimple &&
                !(element.isAd ||
                    element.isTopBanner ||
                    element.isBanner ||
                    element.isTopBanner)),
          )
          .toList();
      _topEstates = value.where((element) => element.isTop).toList();
      _bannerEstates = value.where((element) => element.isBanner).toList();
      _topBannerEstates =
          value.where((element) => element.isTopBanner).toList();
      _adEstates = value.where((element) => element.isAd).toList();
    });
  }

  _changeShow(String key) {
    Map<String, bool> temp = {
      "all": false,
      "simple": false,
      "top": false,
      "banner": false,
      "topbanner": false,
      "ad": false,
    };
    temp[key] = true;
    setState(() {
      _show = temp;
    });

    if (_show["all"] as bool) {
      _currentEstates = _allEstates;
    } else if (_show["simple"] as bool) {
      _currentEstates = _simpleEstates;
    } else if (_show["top"] as bool) {
      _currentEstates = _topEstates;
    } else if (_show["banner"] as bool) {
      _currentEstates = _bannerEstates;
    } else if (_show["topbanner"] as bool) {
      _currentEstates = _topBannerEstates;
    } else if (_show["ad"] as bool) {
      _currentEstates = _adEstates;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      _refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
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
            _openAdsPriceList(context, id);
          },
          "hot": true,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(4);
        return true;
      },
      child: Scaffold(
        appBar: buildNavigationalAppBar(
            context,
            Locales.string(
              context,
              "my_announcements",
            ), () {
          Provider.of<NavigationScreenProvider>(context, listen: false)
              .changePageIndex(4);
        }),
        bottomNavigationBar: _isLoading
            ? null
            : buildBottomNavigation(context, () {
                Navigator.of(context).pop();
              }),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: const EdgeInsets.all(defaultPadding),
                child: RefreshIndicator(onRefresh: () async {
                  _refresh();
                }, child: LayoutBuilder(
                  builder: (context, _) {
                    if (_allEstates.length > 0) {
                      return Column(
                        children: [
                          const SizedBox(height: defaultPadding / 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ..._show.keys
                                    .map(
                                      (key) => SmallButton(
                                        Locales.string(context, key),
                                        enabled: _show[key] as bool,
                                        onPressed: () {
                                          _changeShow(key);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: defaultPadding / 4),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [..._estateBlockList()],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          NoResult(
                            text:
                                Locales.string(context, "no_your_own_estates"),
                            photoPath: "assets/images/no_estates.png",
                          ),
                          FluidBigButton(
                              onPress: () {
                                Provider.of<NavigationScreenProvider>(context,
                                        listen: false)
                                    .changePageIndex(2);
                                Navigator.of(context).popUntil(
                                    ModalRoute.withName(
                                        NavigationalAppScreen.routeName));
                              },
                              text:
                                  Locales.string(context, "place_announcement"))
                        ],
                      );
                    }
                  },
                )),
              ),
      ),
    );
  }

  List _estateBlockList() {
    if (_currentEstates.length > 0) {
      return _currentEstates
          .map(
            (estate) => GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(EstateDetailScreen.routeName,
                    arguments: {"id": estate.id, "typeId": estate.typeId});
              },
              child: Card(
                shadowColor: Colors.transparent,
                color: disabledOrange,
                child: Container(
                  width: 100.w,
                  height: 100,
                  padding: EdgeInsets.all(defaultPadding / 2),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          _buildImageBox(estate),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
          .toList();
    } else {
      return [
        NoResult(
          text: Locales.string(context, "no_your_own_estates"),
          photoPath: "assets/images/no_estates.png",
        )
      ];
    }
  }

  _showStatusSnackBar(bool value, {String hint = ""}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: value ? Colors.green : Colors.red,
        content: value
            ? Text(
                hint +
                    Locales.string(
                      context,
                      "action_success_completed",
                    ),
              )
            : Text(
                hint +
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
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        Locales.string(
                          context,
                          "are_you_sure",
                        ),
                        style: const TextStyle(
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
                  style: const TextStyle(color: darkPurple),
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
                style: const TextStyle(color: Colors.white),
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

  void _navigateToEditScreen([String? id]) {
    Navigator.of(context).pushNamed(EstateCreationPageScreen.routeName,
        arguments: {"estateId": id});
  }

  void _openAdsPriceList(BuildContext context, [String? id]) {
    Provider.of<AuthProvider>(context, listen: false)
        .getUserDataWithoutNotifying()
        .then((user) {
      showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(
          minHeight: 450,
          maxHeight: 530,
        ),
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            Locales.string(context, "ad_your_balance"),
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            user!.balance.toString() +
                                " " +
                                Locales.string(context, "sum"),
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            Locales.string(context, "charging_amount"),
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            _adsTotal.toString() +
                                " " +
                                Locales.string(context, "sum"),
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ..._plans
                    .map(
                      (plan) => CheckboxListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _planText(plan),
                            _planPrice(plan, context),
                          ],
                        ),
                        value: _adPlans.contains(plan.slug),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: normalOrange,
                        onChanged: (value) {
                          if (value == true && !_adPlans.contains(plan.slug)) {
                            _adPlans.add(plan.slug);
                            _adsTotal += plan.price;
                          } else {
                            _adPlans.remove(plan.slug);
                            _adsTotal -= plan.price;
                          }
                          setState(() {});
                        },
                      ),
                    )
                    .toList(),
                const SizedBox(height: 10),
                _buildButtonsBox(context, estateId: id),
                const SizedBox(height: 25),
              ],
            );
          },
        ),
      );
    });
  }

  Text _planPrice(AdPlan plan, BuildContext context) {
    return Text(
      "${plan.price.toString()} " +
          Locales.string(
            context,
            "sum",
          ),
      style: plan.available
          ? const TextStyle(fontSize: 12)
          : TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
    );
  }

  Column _planText(AdPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _planTitle(plan),
        _planDescription(plan),
      ],
    );
  }

  Widget _planDescription(AdPlan plan) {
    return SizedBox(
      width: 40.w,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: Text(
              plan.description,
              maxLines: 2,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _planTitle(AdPlan plan) {
    return Text(
      plan.title,
      style: plan.available ? null : TextStyle(color: Colors.grey[500]),
    );
  }

  Padding _buildButtonsBox(BuildContext context, {estateId}) {
    UserModel? user = Provider.of<AuthProvider>(context, listen: false).user;

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
              setState(() {
                _adPlans = [];
                _adsTotal = 0.0;
              });
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
              minimumSize: Size(42.w, 50),
            ),
            child: Text(
              Locales.string(context, "advertise"),
            ),
            onPressed: (user!.balance < _adsTotal || _adPlans.length == 0)
                ? null
                : () {
                    print(_adPlans);
                    if (_adPlans.length == 0) return;
                    _showConfirmAlert(() async {
                      setState(() {
                        _isLoading = true;
                      });
                      _adPlans.forEach((planSlug) async {
                        print(planSlug);
                        bool value = await Provider.of<EstateProvider>(context,
                                listen: false)
                            .advertise(planSlug, int.parse(estateId));
                        String planTitle = _plans.firstWhere(
                            (plan) => plan.slug == planSlug, orElse: () {
                          return AdPlan(
                            id: 0,
                            title: "",
                            description: "",
                            slug: "",
                            days: 0,
                            price: 0,
                            available: false,
                          );
                        }).title;
                        print(value);
                        if (value) {
                          _showStatusSnackBar(value, hint: planTitle);
                        } else {
                          _showStatusSnackBar(value, hint: planTitle);
                        }
                      });
                      _refresh();
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndViews(EstateModel estate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: normalGrey,
              ),
              const SizedBox(width: 5),
              SmallGreyText(
                text: parseDateTime(
                  estate.created as DateTime,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.remove_red_eye,
                size: 15,
                color: normalGrey,
              ),
              const SizedBox(width: 5),
              SmallGreyText(
                text: "${estate.views}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(EstateModel estate) {
    return Row(
      children: [
        const Icon(
          Icons.location_city,
          size: 15,
          color: normalGrey,
        ),
        const SizedBox(width: 5),
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
            style: const TextStyle(
              color: darkPurple,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 5),
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
    String type = "";
    if (estate.isAd) {
      type = Locales.string(context, "ad");
    } else if (estate.isBanner) {
      type = Locales.string(context, "banner");
    } else if (estate.isTopBanner) {
      type = Locales.string(context, "topbanner");
    } else if (estate.isTop) {
      type = Locales.string(context, "top");
    } else {
      type = Locales.string(context, "simple");
    }

    String heading = "";

    int daysLeft = estate.expiryDate.difference(DateTime.now()).inDays;

    if (daysLeft > 0) {
      heading = "${type}: ${daysLeft} ${Locales.string(context, 'days')}";
    } else {
      heading = "${type}: 0 ${Locales.string(context, 'day')}";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              child: Image.network(
                estate.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              child: Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: daysLeft > 0 ? normalOrange : favouriteRed,
                ),
                child: Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 7,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
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
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.purple, Colors.blue],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                Locales.string(context, "hot"),
                                style: const TextStyle(
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
}
