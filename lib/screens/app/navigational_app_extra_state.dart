import 'package:dachaturizm/screens/app/chat/chat_list_screen.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/search/search_screen.dart';
import 'package:dachaturizm/screens/app/user/user_screen.dart';
import 'package:flutter/cupertino.dart';

class NavigationalExtraState {
  List<Widget> screens = [
    HomePageScreen(),
    SearchPageScreen(),
    EstateCreationPageScreen(),
    ChatListScreen(),
    UserPageScreen(),
  ];

  final List<String> appBarTitles = [
    "homescreen_appbar_text",
    "searchpagescreen_appbar_text",
    "estatecreationscreen_appbar_text",
    "chatpagescreen_appbar_text",
    "userpagescreen_appbar_text",
  ];
}
