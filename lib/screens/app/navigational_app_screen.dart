import 'dart:io';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_extra_state.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class NavigationalAppScreen extends StatefulWidget {
  static String routeName = "/navigational-app";

  @override
  State<NavigationalAppScreen> createState() => _NavigationalAppScreenState();
}

class _NavigationalAppScreenState extends State<NavigationalAppScreen>
    with NavigationalExtraState {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<AuthProvider>(context, listen: false).getAccessToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex =
        Provider.of<NavigationScreenProvider>(context).currentIndex;
    return WillPopScope(
      onWillPop: () async {
        if (Provider.of<NavigationScreenProvider>(context, listen: false)
                .currentIndex ==
            0) {
          return exit(0);
        }
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(0);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: currentIndex == 0 ? 78 : null,
          centerTitle: currentIndex == 0 ? false : true,
          title: Consumer<NavigationScreenProvider>(
              builder: (context, navigator, _) {
            if (navigator.currentIndex == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8),
                child: Image.asset(
                  "assets/images/logo-horizontal-sm.png",
                  height: 40,
                ),
              );
            }
            return Text(
              Locales.string(context, appBarTitles[navigator.currentIndex]),
              style:
                  TextStyles.display2().copyWith(fontWeight: FontWeight.w700),
            );
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                onPressed: () async {
                  await callWithAuth(context, () async {
                    Navigator.of(context).pushNamed(WishlistScreen.routeName);
                  });
                },
                icon: const Icon(
                  Icons.favorite_border_rounded,
                  size: 24,
                  color: darkPurple,
                ),
              ),
            )
          ],
        ),
        body: Consumer<NavigationScreenProvider>(
          builder: (context, navigator, _) {
            return IndexedStack(
              index: navigator.currentIndex,
              children: screens,
            );
          },
        ),
        bottomNavigationBar: buildBottomNavigation(context),
      ),
    );
  }
}
