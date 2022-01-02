import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  static const String routeName = "/wishlist";

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<EstateModel> _estates = [];

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      Provider.of<EstateProvider>(context, listen: false)
          .myWishlist()
          .then((value) {
        setState(() {
          _estates = value;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: buildNavigationalAppBar(
            context,
            Locales.string(context, "wishlist"),
          ),
          bottomNavigationBar: buildBottomNavigation(context, () {
            Navigator.of(context).pop();
          }),
          body: Container(
            padding: EdgeInsets.all(defaultPadding),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  (_estates.length == 0)
                      ? Container(
                          height: 60.h,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  child: Image.asset(
                                    "assets/images/e-commerce.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  Locales.string(context, "no_wishlist_items"),
                                  style: TextStyles.display2().copyWith(
                                    height: 1.25,
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Wrap(
                          children: [
                            ..._estates
                                .map((estate) => EstateCard(estate: estate))
                                .toList(),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
