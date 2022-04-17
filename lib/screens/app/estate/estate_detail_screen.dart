import 'dart:async';
import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/get_ip_address.dart';
import 'package:dachaturizm/helpers/parse_datetime.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/models/estate_rating_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/screens/app/cards_block.dart';
import 'package:dachaturizm/screens/app/estate/detail_builders.dart';
import 'package:dachaturizm/screens/app/estate/rating_results.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  int _userId = 0;
  bool _isLiked = false;
  EstateModel? _banner;
  List<EstateModel> _similarEstates = [];
  EstateRatingModel? _estateRating;
  double _rating = 0;

  void showCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  _saveRating() async {
    Provider.of<EstateProvider>(context, listen: false)
        .saveRating(detail.id, _rating)
        .then((_) {
      Provider.of<EstateProvider>(context, listen: false)
          .getEstateRatings(detail.id)
          .then((value) {
        setState(() {
          _estateRating = value;
        });
      });
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration.zero).then((_) async {
      final Map args = ModalRoute.of(context)?.settings.arguments as Map;
      Future.wait([
        Provider.of<AuthProvider>(context, listen: false)
            .getUserId()
            .then((userId) {
          if (userId != null) {
            _userId = userId;
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
          });
        }),
        Provider.of<EstateProvider>(context, listen: false)
            .getEstateRatings(args["id"])
            .then((value) {
          _estateRating = value;
        }),
        Provider.of<EstateProvider>(context, listen: false)
            .getSimilarEstates(args["id"])
            .then((value) {
          _similarEstates = value;
        }),
      ]).then((_) async {
        Future.delayed(Duration(seconds: 1)).then(
          (_) => setState(() {
            isLoading = false;
          }),
        );
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

    return Scaffold(
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
                          visible: _banner != null && _banner!.id != detail.id,
                          child: Padding(
                            padding: const EdgeInsets.only(top: defaultPadding),
                            child: HorizontalAd(_banner as EstateModel),
                          ),
                        ),
                        _detailBuilder.buildSlideShow(context),
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
                                context,
                                showCalendar,
                              ),
                              _detailBuilder.buildCustomCalendar(
                                  context, _showCalendar),
                              _detailBuilder.drawDivider(),
                              SizedBox(height: defaultPadding),
                              _detailBuilder.buildDescription(context),
                              _detailBuilder.buildPopularPlaceBox(context),
                              _detailBuilder.buildAddressBox(context),
                              _detailBuilder.buildChips(),
                              _detailBuilder.buildAnnouncerBox(context),
                              buildRatingResults(context, _estateRating),
                              SizedBox(height: 20),
                              _buildRatingSaver(context),
                              SizedBox(height: 10),
                              _buildSimilarEstates(context),
                              SizedBox(height: 10),
                              _buildExtraInfo(context),
                              SizedBox(height: 10),
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
    );
  }

  Widget _buildExtraInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${Locales.string(context, 'id_number')} ${detail.id}",
          style: TextStyles.display8(),
        ),
        Text(
          "${Locales.string(context, 'placed')} ${parseDateTime(detail.created)}",
          style: TextStyles.display8(),
        ),
        Text(
          "${Locales.string(context, 'views')} ${detail.views}",
          style: TextStyles.display8(),
        ),
      ],
    );
  }

  Widget _buildSimilarEstates(BuildContext context) {
    return Visibility(
      visible: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Locales.string(context, "similar_estates"),
            style: TextStyles.display7(),
          ),
          const SizedBox(height: 10),
          buildCardsBlock(context, _similarEstates, padding: EdgeInsets.all(0)),
        ],
      ),
    );
  }

  Column _buildRatingSaver(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 30,
          itemBuilder: (context, _) => Icon(
            Icons.star_rounded,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            _rating = rating;
          },
        ),
        const SizedBox(height: 10),
        FluidBigButton(
          onPress: () {
            callWithAuth(context, () {
              _saveRating();
            });
          },
          text: Locales.string(context, "send"),
          size: const Size(180, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          height: 1,
          color: lightGrey,
        )
      ],
    );
  }

  AppBar _buildAppBar(
      BuildContext context, String share_url, String share_title) {
    return buildNavigationalAppBar(
      context,
      Locales.string(context, "detail"),
      null,
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
