import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/search/search_screen.dart';
import 'package:dachaturizm/screens/app/user/user_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class NavigationalAppScreen extends StatefulWidget {
  const NavigationalAppScreen({Key? key}) : super(key: key);

  static String routeName = "/navigational-app";

  @override
  _NavigationalAppScreenState createState() => _NavigationalAppScreenState();
}

class _NavigationalAppScreenState extends State<NavigationalAppScreen> {
  final _screens = [
    HomePageScreen(),
    SearchPageScreen(),
    EstateCreationPageScreen(),
    ChatPageScreen(),
    UserPageScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: Consumer<NavigationScreenProvider>(
          builder: (context, navigator, _) {
            return IndexedStack(
              index: navigator.currentIndex,
              children: _screens,
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigation() {
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
            .changePageIndex(index);
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
