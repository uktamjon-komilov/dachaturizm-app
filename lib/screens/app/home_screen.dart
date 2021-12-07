import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/components/search_bar.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/widgets/type_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  static String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  var _isLoading = true;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    _refreshHomePage();
    super.didChangeDependencies();
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) {
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
                  .then(
                    (_) => setState(() {
                      _isLoading = false;
                    }),
                  );
            });
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final int screenWidth = queryData.size.width.toInt();
    final int screenHeight = queryData.size.height.toInt();

    return Scaffold(
      appBar: AppBar(
        title: LocaleText("appbar_text"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.favorite_border_outlined,
              size: 30,
              color: Colors.redAccent,
            ),
          )
        ],
      ),
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
                    SearchBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildBannerBlock(
                              context,
                              screenWidth,
                              Provider.of<BannerProvider>(context,
                                      listen: false)
                                  .topBanners,
                            ),
                            EstateTypeListView(),
                            ...Provider.of<EstateTypesProvider>(context,
                                    listen: false)
                                .items
                                .map((item) =>
                                    _buildEstateTypeBlock(screenWidth, item))
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

  Container _buildBannerBlock(
      BuildContext context, int screenWidth, List banners) {
    if (banners.length > 0) print(banners[0].photo);

    return Container(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          ...banners
              .map((banner) => _buildBannerItem(banner, screenWidth))
              .toList()
        ],
      ),
    );
  }

  Widget _buildBannerItem(EstateModel estate, int screenWidth) {
    return Row(
      children: [
        HorizontalAd(
          estate,
          width: screenWidth * 0.8,
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _buildEstateTypeBlock(int screenWidth, TypeModel type) {
    List topEstates = Provider.of<EstateProvider>(context, listen: false)
        .getTopEstatesByType(type.id);
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
                      TextLinkButton(Locales.string(context, "all"), () {})
                    ],
                  ),
                ),
                (topEstates.length > 0)
                    ? Wrap(
                        children: [
                          ...topEstates
                              .map((estate) => EstateCard(
                                  screenWidth: screenWidth, estate: estate))
                              .toList()
                        ],
                      )
                    : Container(),
                (banners[type.id].length > 0)
                    ? _buildBannerBlock(
                        context,
                        screenWidth,
                        banners[type.id],
                      )
                    : Container(),
              ],
            ),
          )
        : Container();
  }
}
