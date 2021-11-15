import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/estate_providers.dart';
import 'package:dachaturizm/screens/app/chat_screen.dart';
import 'package:dachaturizm/screens/app/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/listing_screen.dart';
import 'package:dachaturizm/screens/app/home_screen.dart';
import 'package:dachaturizm/screens/app/search_screen.dart';
import 'package:dachaturizm/screens/app/user_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/type_provider.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EstateTypes>(
          create: (ctx) => EstateTypes(),
        ),
        ChangeNotifierProvider<EstateProvider>(
          create: (ctx) => EstateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: _buildBottomNavigation(),
          ),
        ),
        // initialRoute: "/on-boarding",
        routes: {
          EstateListingScreen.routeName: (context) => EstateListingScreen(),
          EstateDetailScreen.routeName: (context) => EstateDetailScreen(),
          // "/on-boarding": (context) => const OnBoardLoading(),
          // "/auth-type": (context) => AuthType(),
          // "/start-choose-lang": (context) => const LoadingChooseLangScreen(),
          // "/home-page": (context) => const HomePageScreen(),
        },
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
