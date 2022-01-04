import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildBottomNavigation(BuildContext context, [Function? popCallback]) {
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
        // Provider.of<NavigationScreenProvider>(context, listen: false)
        //     .clearData();
      }
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .changePageIndex(index, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      if (popCallback != null) {
        popCallback();
      }
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
