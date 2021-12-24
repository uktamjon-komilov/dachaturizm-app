import 'dart:async';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/get_my_location.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/estate/detail_builders.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:share/share.dart';

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
  var _location;
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

  void showCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  PreferredSizeWidget _buildAppBar(EstateModel estate) {
    String share_url = "https://dachaturizm.uz/";
    String share_title = "Look I have discovered something!";
    try {
      List<TypeModel> items =
          Provider.of<EstateTypesProvider>(context, listen: false).items;
      TypeModel type = items.where((item) => item.id == estate.typeId).first;
      share_url = "https://dachaturizm.uz/estate/${type.slug}/${estate.id}/";
    } catch (e) {
      share_url = "https://dachaturizm.uz/";
    }

    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: darkPurple,
      ),
      title: Text(
        Locales.string(context, "detail"),
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
          onPressed: () {
            Share.share(
              share_url,
              subject: share_title,
            );
          },
          icon: Icon(
            Icons.send_rounded,
          ),
        ),
        IconButton(
          onPressed: () async {
            bool original = _isLiked;
            await callWithAuth(() async {
              setState(() {
                _isLiked = !_isLiked;
              });
              Provider.of<EstateProvider>(context, listen: false)
                  .toggleWishlist(estate.id, original)
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
            _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
            color: _isLiked ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  void didChangeDependencies() {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;

    Future.delayed(Duration.zero).then((_) {
      getLocation().then((location) {
        _location = location;
        Provider.of<EstateProvider>(context, listen: false)
            .fetchEstateById(args["id"])
            .then((estate) {
          setState(() {
            detail = estate;
            _isLiked = estate.isLiked;
            _detailBuilder = DetailBuilder(detail);
            Future.delayed(Duration(seconds: 1)).then(
              (_) => setState(() {
                isLoading = false;
              }),
            );
          });
        });
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;
    final int estateId = args["id"];

    final halfScreenButtonWidth = (100.w - 3 * defaultPadding) / 2;

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(detail),
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
                              horizontal: defaultPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailBuilder.buildTitle(),
                                _detailBuilder.buildRatingRow(context),
                                _detailBuilder.buildPriceRow(
                                    context, showCalendar),
                                _detailBuilder.drawDivider(),
                                _showCalendar
                                    ? _detailBuilder
                                        .buildCustomCalendar(context)
                                    : SizedBox(),
                                _detailBuilder.drawDivider(),
                                _detailBuilder.buildDescription(context),
                                _detailBuilder.buildAddressBox(
                                    context, _location),
                                _detailBuilder.buildChips(),
                                _detailBuilder.buildAnnouncerBox(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _detailBuilder.buildContactBox(context, halfScreenButtonWidth)
                ],
              ),
      ),
    );
  }
}
