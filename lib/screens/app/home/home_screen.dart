import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/category_item.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/screens/app/home/services_list_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

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

  @override
  void didChangeDependencies() async {
    bool shouldRefresh =
        Provider.of<NavigationScreenProvider>(context).refreshHomePage;
    if (shouldRefresh) {
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buidlCategoryRow(context),
                          SizedBox(height: 24),
                          _buildSearchBar(context),
                          _buildTopBannerBlock(
                            context,
                            Provider.of<BannerProvider>(context).topBanners,
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                defaultPadding, 24, defaultPadding, 0),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              children: [
                                ...Provider.of<EstateTypesProvider>(context)
                                    .items
                                    .map((item) => _buildEstateTypeBlock(item))
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
            String term = _searchController.text;
            _searchController.text = "";
            Provider.of<NavigationScreenProvider>(context, listen: false)
                .visitSearchPage(term);
          }
        },
      ),
    );
  }

  Future<void> _refreshHomePage() async {
    Future.delayed(Duration.zero).then((_) {
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
    });
  }

  Widget _buildCardsBlock(BuildContext context, List estates) {
    if (estates.length > 4) estates = estates.sublist(0, 4);

    return estates.length == 0
        ? Container()
        : Container(
            width: 100.w,
            padding: EdgeInsets.only(top: defaultPadding),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 6,
              children: [
                ...estates.map((estate) => EstateCard(estate: estate)).toList(),
              ],
            ),
          );
  }

  Widget _buildTopBannerBlock(BuildContext context, List banners) {
    if (banners.length > 4) banners = banners.sublist(0, 4);

    return banners.length == 0
        ? Container()
        : Container(
            height: 190,
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                ...banners.map((banner) => _buildBannerItem(banner)).toList()
              ],
            ),
          );
  }

  Widget _buildBannerBlock(BuildContext context, List banners) {
    if (banners.length > 4) banners = banners.sublist(0, 4);

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
          width: defaultPadding,
        ),
      ],
    );
  }

  Widget _buildEstateTypeBlock(TypeModel type) {
    List topEstates = Provider.of<EstateProvider>(context, listen: false)
        .getEstatesByType(type.id, top: true);
    Map banners = Provider.of<BannerProvider>(context).banners;

    return (topEstates.length > 0 || banners[type.id].length > 0)
        ? Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Locales.string(context, "top") +
                          " ${type.title.toLowerCase()}",
                      style: TextStyles.display2(),
                    ),
                    TextLinkButton(Locales.string(context, "all"), () {
                      Navigator.of(context).pushNamed(
                        EstateListingScreen.routeName,
                        arguments: type.id,
                      );
                    })
                  ],
                ),
                (topEstates.length > 0)
                    ? _buildCardsBlock(context, topEstates)
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

  Widget _buidlCategoryRow(BuildContext context) {
    return Container(
      height: 133,
      padding: EdgeInsets.symmetric(horizontal: 16),
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
                ...Provider.of<EstateTypesProvider>(context).items.map((item) {
                  return Container(
                    margin: EdgeInsets.only(right: 34),
                    child: CategoryItem(
                      title: item.title,
                      icon: item.icon,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          EstateListingScreen.routeName,
                          arguments: item.id,
                        );
                      },
                    ),
                  );
                }).toList(),
                Container(
                  margin: EdgeInsets.only(right: 34),
                  child: CategoryItem(
                    title: "Xizmatlar",
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
