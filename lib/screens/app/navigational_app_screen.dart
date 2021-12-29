import 'dart:io';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/chat/chat_list_screen.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/search/search_screen.dart';
import 'package:dachaturizm/screens/app/user/user_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
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
    ChatListScreen(),
    UserPageScreen()
  ];

  final List<String> appBarTitles = [
    "homescreen_appbar_text",
    "searchpagescreen_appbar_text",
    "estatecreationscreen_appbar_text",
    "chatpagescreen_appbar_text",
    "userpagescreen_appbar_text",
  ];

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
            toolbarHeight:
                Provider.of<NavigationScreenProvider>(context).currentIndex == 0
                    ? 78
                    : null,
            centerTitle: false,
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
              return LocaleText(appBarTitles[navigator.currentIndex]);
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
                  icon: Icon(
                    Icons.favorite_border_rounded,
                    size: 24,
                    color: favouriteRed,
                  ),
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
    int currentIndex =
        Provider.of<NavigationScreenProvider>(context).currentIndex;

    return BottomNavigationBar(
      selectedLabelStyle: TextStyles.display4(),
      unselectedLabelStyle:
          TextStyles.display4().copyWith(color: Color(0xFFBDBDBD)),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
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
            currentIndex == 0
                ? Icons.dashboard_rounded
                : Icons.dashboard_outlined,
            color: currentIndex == 0 ? darkPurple : Color(0xFFBDBDBD),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1 ? Icons.search_rounded : Icons.search_outlined,
            color: currentIndex == 1 ? darkPurple : Color(0xFFBDBDBD),
          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2
                ? Icons.add_circle_rounded
                : Icons.add_circle_outline_rounded,
            color: currentIndex == 2 ? darkPurple : Color(0xFFBDBDBD),
          ),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Container(
            child: Center(
              child: Stack(children: [
                Icon(
                  currentIndex == 3
                      ? Icons.question_answer_rounded
                      : Icons.question_answer_outlined,
                  color: currentIndex == 3 ? darkPurple : Color(0xFFBDBDBD),
                ),
                Visibility(
                  visible: Provider.of<NavigationScreenProvider>(context)
                          .unreadMessagesCount >
                      0,
                  child: Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: normalOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Provider.of<NavigationScreenProvider>(context).currentIndex == 4
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            color: currentIndex == 4 ? darkPurple : Color(0xFFBDBDBD),
          ),
          label: "User",
        ),
      ],
    );
  }
}
