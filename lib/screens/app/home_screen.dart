import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/horizontal_ad.dart';
import 'package:dachaturizm/components/search_bar.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/locale_helper.dart';
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
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) {
      Provider.of<EstateTypes>(context, listen: false).fetchAndSetTypes().then(
            (_) => {
              Provider.of<EstateProvider>(context, listen: false)
                  .fetchAllAndSetEstates()
                  .then(
                    (_) => setState(() {
                      _isLoading = false;
                    }),
                  ),
            },
          );
    });
    super.didChangeDependencies();
  }

  Future<void> _refreshHomePage() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) {
      Provider.of<EstateTypes>(context, listen: false)
          .fetchAndSetTypes()
          .then((_) => {
                Provider.of<EstateProvider>(context, listen: false)
                    .fetchAllAndSetEstates()
                    .then((_) => setState(() {
                          _isLoading = false;
                        }))
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
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding),
                child: Column(
                  children: [
                    SearchBar(),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          EstateTypeListView(),
                          ...Provider.of<EstateTypes>(context, listen: false)
                              .items
                              .map((item) =>
                                  _buildEstateTypeBlock(screenWidth, item))
                              .toList(),
                          // _buildEstateTypeBlock(screenWidth),
                          // _buildEstateTypeBlock(screenWidth),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
    );
  }

  Container _buildEstateTypeBlock(int screenWidth, TypeModel type) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text1("To'p ${type.title}"),
                TextLinkButton("Barchasi", "/top")
              ],
            ),
          ),
          Wrap(
            children: [
              ...Provider.of<EstateProvider>(context, listen: false)
                  .getTopEstatesByType(type.id)
                  .map((estate) =>
                      EstateCard(screenWidth: screenWidth, estate: estate))
                  .toList()
              // EstateCard(screenWidth: screenWidth),
              // EstateCard(screenWidth: screenWidth),
            ],
          ),
          HorizontalAd()
        ],
      ),
    );
  }
}
