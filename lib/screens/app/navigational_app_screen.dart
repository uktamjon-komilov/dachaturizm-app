import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/app/chat_screen.dart';
import 'package:dachaturizm/screens/app/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/home_screen.dart';
import 'package:dachaturizm/screens/app/search_screen.dart';
import 'package:dachaturizm/screens/app/user_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';

class NavigationalAppScreen extends StatefulWidget {
  const NavigationalAppScreen({Key? key}) : super(key: key);

  static String routeName = "/navigational-app";

  @override
  _NavigationalAppScreenState createState() => _NavigationalAppScreenState();
}

class _NavigationalAppScreenState extends State<NavigationalAppScreen> {
  int _currentIndex = 0;

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
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
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
      currentIndex: _currentIndex,
      onTap: (index) => setState(() {
        _currentIndex = index;
      }),
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
            color: darkPurple,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 1 ? Icons.search_outlined : Icons.search,
            color: darkPurple,
          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 2
                ? Icons.add_circle_rounded
                : Icons.add_circle_outline_rounded,
            color: darkPurple,
          ),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 3 ? Icons.chat_rounded : Icons.chat_outlined,
            color: darkPurple,
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _currentIndex == 4
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
