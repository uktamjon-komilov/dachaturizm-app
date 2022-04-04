import 'dart:async';

import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/category_item.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/remove_doubles.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/screens/app/home/services_list_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  static String routeName = "/home";

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  int _topBannerIndex = 0;
  final CarouselController _topBannerController = CarouselController();

  Future<void> _refreshHomePage() async {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<BannerProvider>(context, listen: false).getTopBanners();
      Provider.of<EstateTypesProvider>(context, listen: false)
          .getCategories()
          .then(
        (types) {
          Future.wait([
            Provider.of<BannerProvider>(context, listen: false)
                .getBanners(types),
            Provider.of<EstateProvider>(context, listen: false)
                .getTopEstates(types),
          ]).then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        },
      );
    });
  }

  _navigateToCategory(BuildContext context, CategoryModel category) {
    Navigator.of(context).pushNamed(
      EstateListingScreen.routeName,
      arguments: category,
    );
  }

  _search(context) {
    String term = _searchController.text;
    _searchController.text = "";
    Provider.of<NavigationScreenProvider>(context, listen: false)
        .visitSearchPage(term);
  }

  @override
  void didChangeDependencies() async {
    bool shouldRefresh =
        Provider.of<NavigationScreenProvider>(context).refreshHomePage;
    if (shouldRefresh) {
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .setHomeData = {"refresh_callback": _refreshHomePage};
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .refreshHomePage = false;
      await _refreshHomePage();
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) {
      FocusScope.of(context).unfocus();
      _searchController.clear();
      _refreshHomePage();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<CategoryModel> categories =
        Provider.of<EstateTypesProvider>(context).categories;
    List<EstateModel> topBanners =
        Provider.of<BannerProvider>(context).topBanners;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshHomePage,
              child: Column(
                children: [
                  Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overScroll) {
                        overScroll.disallowGlow();
                        return false;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buidlCategoryRow(context, categories),
                            SizedBox(height: defaultPadding * 0.5),
                            _buildBannerBlock(
                                context, topBanners, _topBannerIndex),
                            SizedBox(height: defaultPadding * 0.5),
                            Visibility(
                              visible: categories.length > 0 &&
                                  Provider.of<BannerProvider>(context)
                                          .banners
                                          .keys
                                          .length >
                                      0 &&
                                  Provider.of<EstateProvider>(context)
                                          .topEstates
                                          .keys
                                          .length >
                                      0,
                              replacement: Container(
                                height: 150,
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: disabledGrey,
                                        ),
                                        iconSize: 50,
                                        onPressed: () {
                                          _refreshHomePage();
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        Locales.string(context,
                                            "refresh_to_get_new_results"),
                                        style: TextStyle(
                                          color: disabledGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              child: _showCategoryRelatedItems(categories),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _showCategoryRelatedItems(List<CategoryModel> categories) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        defaultPadding,
        24,
        defaultPadding,
        defaultPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          ...categories.map((item) => _buildEstateTypeBlock(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: defaultPadding,
        right: defaultPadding,
        // bottom: defaultPadding,
      ),
      child: SearchBarWithFilter(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: false,
        onSubmit: (value) {
          if (value != "") {
            _search(context);
          }
        },
        onFilterCallback: () => _search(context),
      ),
    );
  }

  Widget _buildCardsBlock(BuildContext context, List? estates) {
    try {
      if (estates != null && estates.length > 4)
        estates = estates.sublist(0, 4);
      return Visibility(
        visible: estates != null,
        child: Container(
          width: 100.w,
          padding: EdgeInsets.only(top: defaultPadding / 2),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              ...estates!.map((estate) => EstateCard(estate: estate)).toList(),
            ],
          ),
        ),
      );
    } catch (e) {
      return Visibility(visible: false, child: Container());
    }
  }

  Widget _buildBannerBlock(
      BuildContext context, List? banners, int currentIndex) {
    return Visibility(
      visible: banners!.length > 0,
      child: Container(
        height: 210,
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                scrollDirection: Axis.horizontal,
              ),
              items: banners.map((banner) {
                return Builder(
                  builder: (BuildContext context) {
                    return _buildBannerItem(banner);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(EstateModel estate) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: HorizontalAd(
        estate,
      ),
    );
  }

  Widget _buildEstateTypeBlock(CategoryModel category) {
    List<EstateModel> topEstates =
        Provider.of<EstateProvider>(context).topEstates[category.id];
    List banners = Provider.of<BannerProvider>(context).banners[category.id];

    topEstates.shuffle();
    topEstates = removeDoubleEstates(topEstates);

    return Visibility(
      visible: (topEstates != null &&
          banners != null &&
          (topEstates.length > 0 || banners.length > 0)),
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: normalOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.fromLTRB(7, 0, 7, 3),
                  child: Text(
                    Locales.string(context, "top") +
                        " ${category.title.toLowerCase()}",
                    style: TextStyles.display2().copyWith(color: Colors.white),
                  ),
                ),
                TextLinkButton(Locales.string(context, "all"), () {
                  _navigateToCategory(context, category);
                })
              ],
            ),
            _buildCardsBlock(context, topEstates),
            _buildBannerBlock(context, banners, _topBannerIndex)
          ],
        ),
      ),
    );
  }

  Widget _buidlCategoryRow(BuildContext context, List categories) {
    return Container(
      height: 100,
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...categories.map((item) {
                  return Container(
                    margin: EdgeInsets.only(right: 30),
                    child: CategoryItem(
                      title: item.title,
                      icon: item.icon,
                      onTap: () {
                        _navigateToCategory(context, item);
                      },
                    ),
                  );
                }).toList(),
                Container(
                  margin: EdgeInsets.only(right: 30),
                  child: CategoryItem(
                    title: Locales.string(context, "services"),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ServicesListScreen.routeName);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
