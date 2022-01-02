import 'dart:async';

import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/get_ip_address.dart';
import 'package:dachaturizm/helpers/get_my_location.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/screens/app/estate/detail_builders.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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
  int _userId = 0;
  bool _isLiked = false;
  EstateModel? _banner;
  List<EstateModel> _userEstates = [];

  void showCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map args = ModalRoute.of(context)?.settings.arguments as Map;

    Future.delayed(Duration.zero).then((_) async {
      Future.wait([
        Provider.of<AuthProvider>(context, listen: false)
            .getUserId()
            .then((userId) {
          if (userId != null) {
            _userId = int.parse(userId);
          }
        }),
        Provider.of<EstateProvider>(context, listen: false)
            .getAd()
            .then((value) => _banner = value),
        Provider.of<EstateProvider>(context, listen: false)
            .getEstateById(args["id"])
            .then((estate) async {
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
        }),
      ]).then((_) async {
        Dio dio = Provider.of<AuthProvider>(context, listen: false).dio;
        final ip = await getPublicIP(dio);
        if (ip == null) {
        } else {
          Provider.of<EstateProvider>(context, listen: false)
              .addEstateView(ip, detail.id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map;
    bool fromChat = args.containsKey("fromChat");

    String share_url = "${baseFrontUrl}";
    String share_title = "Look I have discovered something!";
    try {
      List<CategoryModel> categories =
          Provider.of<EstateTypesProvider>(context, listen: false).categories;
      CategoryModel type =
          categories.where((item) => item.id == detail.typeId).first;
      share_url += "estate/${type.slug}/${detail.id}/";
    } catch (e) {}

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context, share_url, share_title),
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
                          Visibility(
                            visible: _banner != null,
                            child: HorizontalAd(_banner as EstateModel),
                          ),
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
                                _showCalendar
                                    ? _detailBuilder
                                        .buildCustomCalendar(context)
                                    : SizedBox(),
                                _detailBuilder.drawDivider(),
                                SizedBox(height: defaultPadding),
                                _detailBuilder.buildDescription(context),
                                _detailBuilder.buildAddressBox(
                                  context,
                                  _location,
                                ),
                                _detailBuilder.buildChips(),
                                _detailBuilder.buildAnnouncerBox(context),
                                Visibility(
                                  visible: _userEstates.length > 0,
                                  child: Column(
                                    children: [
                                      Text(Locales.string(
                                          context, "similar_estates"))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _detailBuilder.buildContactBox(context, fromChat, _userId),
                ],
              ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, String share_url, String share_title) {
    return buildNavigationalAppBar(
      context,
      Locales.string(context, "detail"),
      () {
        Navigator.of(context).pop();
      },
      [
        IconButton(
          onPressed: () {
            Share.share(
              share_url,
              subject: share_title,
            );
          },
          icon: SvgPicture.asset(
            "assets/icons/share.svg",
            color: darkPurple,
          ),
        ),
        IconButton(
          onPressed: () async {
            bool original = _isLiked;
            await callWithAuth(context, () async {
              setState(() {
                _isLiked = !_isLiked;
              });
              Provider.of<EstateProvider>(context, listen: false)
                  .toggleWishlist(detail.id, original)
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
            color: _isLiked ? favouriteRed : darkPurple,
          ),
        ),
      ],
    );
  }
}
