import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/components/search_bar.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/components/type_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  static String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      _refreshHomePage();
    });
    super.initState();
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<BannerProvider>(context, listen: false)
        .getAndSetTopBanners()
        .then((_) {
      Provider.of<EstateTypesProvider>(context, listen: false)
          .fetchAndSetTypes()
          .then(
        (types) {
          Provider.of<BannerProvider>(context, listen: false)
              .getAndSetBanners(types)
              .then((banners) {
            Provider.of<EstateProvider>(context, listen: false)
                .fetchAllAndSetEstates()
                .then((_) {
              setState(() {
                _isLoading = false;
              });
            });
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshHomePage,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    defaultPadding, defaultPadding, defaultPadding, 0),
                child: Column(
                  children: [
                    SearchBar(
                      controller: _searchController,
                      onSubmit: (value) {
                        if (value != "") {
                          String term = _searchController.text;
                          _searchController.text = "";
                          Provider.of<NavigationScreenProvider>(context,
                                  listen: false)
                              .visitSearchPage(term);
                        }
                      },
                      onChange: (value) {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildBannerBlock(
                              context,
                              Provider.of<BannerProvider>(context,
                                      listen: false)
                                  .topBanners,
                            ),
                            EstateTypeListView(),
                            ...Provider.of<EstateTypesProvider>(
                              context,
                            )
                                .items
                                .map((item) => _buildEstateTypeBlock(item))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Container _buildBannerBlock(BuildContext context, List banners) {
    if (banners.length > 6) banners = banners.sublist(0, 6);

    return banners.length == 0
        ? Container()
        : Container(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                ...banners.map((banner) => _buildBannerItem(banner)).toList()
              ],
            ),
          );
  }

  Widget _buildBannerItem(EstateModel estate) {
    return Row(
      children: [
        HorizontalAd(
          estate,
          width: 100.w * 0.8,
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _buildEstateTypeBlock(TypeModel type) {
    List topEstates = Provider.of<EstateProvider>(context, listen: false)
        .getEstatesByType(type.id, top: true);
    Map banners = Provider.of<BannerProvider>(context, listen: false).banners;

    return (topEstates.length > 0 || banners[type.id].length > 0)
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text1(Locales.string(context, "top") +
                          " ${type.title.toLowerCase()}"),
                      TextLinkButton(Locales.string(context, "all"), () {
                        Navigator.of(context).pushNamed(
                          EstateListingScreen.routeName,
                          arguments: type.id,
                        );
                      })
                    ],
                  ),
                ),
                (topEstates.length > 0)
                    ? Container(
                        width: 100.w,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: [
                            ...topEstates
                                .map((estate) => EstateCard(estate: estate))
                                .toList(),
                          ],
                        ),
                      )
                    : Container(),
                (banners[type.id].length > 0)
                    ? _buildBannerBlock(
                        context,
                        banners[type.id],
                      )
                    : Container(),
              ],
            ),
          )
        : Container();
  }
}
