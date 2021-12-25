import 'dart:io';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/search/search_screen.dart';
import 'package:dachaturizm/screens/app/user/user_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class NavigationalAppScreen extends StatefulWidget {
  static String routeName = "/navigational-app";

  @override
  State<NavigationalAppScreen> createState() => _NavigationalAppScreenState();
}

class _NavigationalAppScreenState extends State<NavigationalAppScreen> {
  final _screens = [
    HomePageScreen(),
    SearchPageScreen(),
    EstateCreationPageScreen(),
    ChatPageScreen(),
    UserPageScreen()
  ];

  final List<String> appBarTitles = [
    "homescreen_appbar_text",
    "searchpagescreen_appbar_text",
    "estatecreationscreen_appbar_text",
    "chatpagescreen_appbar_text",
    "userpagescreen_appbar_text",
  ];

  _showLoginScreen() async {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<AuthProvider>(context, listen: false).getAccessToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print(Provider.of<NavigationScreenProvider>(context, listen: false)
            .currentIndex);
        if (Provider.of<NavigationScreenProvider>(context, listen: false)
                .currentIndex ==
            0) {
          return exit(0);
        }
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(0);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Consumer<NavigationScreenProvider>(
                builder: (context, navigator, _) {
              return LocaleText(appBarTitles[navigator.currentIndex]);
            }),
            actions: [
              IconButton(
                onPressed: () async {
                  await callWithAuth(() async {
                    Navigator.of(context).pushNamed(WishlistScreen.routeName);
                  });
                },
                icon: Icon(
                  Icons.favorite_border_outlined,
                  size: 30,
                  color: Colors.redAccent,
                ),
              )
            ],
          ),
          body: Consumer<NavigationScreenProvider>(
            builder: (context, navigator, _) {
              return IndexedStack(
                index: navigator.currentIndex,
                children: _screens,
              );
            },
          ),
          bottomNavigationBar: _buildBottomNavigation(context),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: Provider.of<NavigationScreenProvider>(context).currentIndex,
      onTap: (index) {
        if (index != 1) {
          Provider.of<NavigationScreenProvider>(context, listen: false)
              .clearData();
        }
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(index, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 0
                ? Icons.home_rounded
                : Icons.home_outlined,
            color: darkPurple,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 1
                ? Icons.search_outlined
                : Icons.search,
            color: darkPurple,
          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 2
                ? Icons.add_circle_rounded
                : Icons.add_circle_outline_rounded,
            color: darkPurple,
          ),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 3
                ? Icons.chat_rounded
                : Icons.chat_outlined,
            color: darkPurple,
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 4
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            color: darkPurple,
          ),
          label: "User",
        ),
      ],
    );
  }
}
